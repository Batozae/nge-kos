import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/kost.dart';
import 'session_store.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  ApiException(this.code, this.message, {this.statusCode});

  // Token tidak ada, salah, atau kedaluwarsa
  bool get sesiBerakhir => statusCode == 401;

  @override
  String toString() => message;
}

class ApiService {
  // Bisa diganti saat menjalankan: --dart-define=API_BASE_URL=https://alamat-server
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const Duration _batasWaktu = Duration(seconds: 10);

  // ---------- Fungsi dasar ----------

  static ApiException _bacaError(int statusCode, String teksBody) {
    dynamic body;
    try {
      body = jsonDecode(teksBody);
    } catch (_) {
      body = null;
    }
    final Map err = (body is Map && body['error'] is Map)
        ? body['error'] as Map
        : {};
    return ApiException(
      err['code']?.toString() ?? 'UNKNOWN',
      err['message']?.toString() ?? 'Terjadi kesalahan',
      statusCode: statusCode,
    );
  }

  static Future<http.Response> _kirim(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool pakaiToken = false,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      if (body != null) 'Content-Type': 'application/json',
      if (pakaiToken && SessionStore.token != null)
        'Authorization': 'Bearer ${SessionStore.token}',
    };
    final isi = body == null ? null : jsonEncode(body);

    final Future<http.Response> permintaan = switch (method) {
      'GET' => http.get(uri, headers: headers),
      'POST' => http.post(uri, headers: headers, body: isi),
      'PUT' => http.put(uri, headers: headers, body: isi),
      'DELETE' => http.delete(uri, headers: headers),
      _ => throw ArgumentError('Method tidak didukung: $method'),
    };
    return permintaan.timeout(_batasWaktu);
  }

  static Map<String, dynamic> _bacaSukses(
    http.Response response,
    int statusSukses,
  ) {
    if (response.statusCode != statusSukses) {
      throw _bacaError(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static List<Kost> _daftarKost(Map<String, dynamic> data) {
    return (data['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(Kost.fromJson)
        .toList();
  }

  static void _simpanSesi(Map<String, dynamic> data) {
    SessionStore.simpan(
      data['token'] as String,
      AppUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  // ---------- Kost (publik) ----------

  static Future<List<Kost>> fetchKostList({Map<String, String>? query}) async {
    final path = Uri(path: '/kost', queryParameters: query).toString();
    return _daftarKost(_bacaSukses(await _kirim('GET', path), 200));
  }

  static Future<Kost> fetchKostDetail(String id) async {
    final data = _bacaSukses(await _kirim('GET', '/kost/$id'), 200);
    return Kost.fromJson(data['data'] as Map<String, dynamic>);
  }

  // ---------- Kost (khusus pemilik, butuh token) ----------

  static Future<List<Kost>> fetchKostSaya() async {
    final response = await _kirim('GET', '/owner/kost', pakaiToken: true);
    return _daftarKost(_bacaSukses(response, 200));
  }

  static Future<Kost> buatKost(Map<String, dynamic> data) async {
    final response = await _kirim(
      'POST',
      '/kost',
      body: data,
      pakaiToken: true,
    );
    final hasil = _bacaSukses(response, 201);
    return Kost.fromJson(hasil['data'] as Map<String, dynamic>);
  }

  static Future<Kost> ubahKost(String id, Map<String, dynamic> data) async {
    final response = await _kirim(
      'PUT',
      '/kost/$id',
      body: data,
      pakaiToken: true,
    );
    final hasil = _bacaSukses(response, 200);
    return Kost.fromJson(hasil['data'] as Map<String, dynamic>);
  }

  static Future<void> hapusKost(String id) async {
    final response = await _kirim('DELETE', '/kost/$id', pakaiToken: true);
    if (response.statusCode != 204) {
      throw _bacaError(response.statusCode, response.body);
    }
  }

  // ---------- Favorit (khusus pencari, butuh token) ----------

  static Future<List<Kost>> fetchFavorit() async {
    final response = await _kirim('GET', '/favorit', pakaiToken: true);
    return _daftarKost(_bacaSukses(response, 200));
  }

  static Future<void> tambahFavorit(String kostId) async {
    final response = await _kirim('PUT', '/favorit/$kostId', pakaiToken: true);
    if (response.statusCode != 204) {
      throw _bacaError(response.statusCode, response.body);
    }
  }

  static Future<void> hapusFavorit(String kostId) async {
    final response = await _kirim(
      'DELETE',
      '/favorit/$kostId',
      pakaiToken: true,
    );
    if (response.statusCode != 204) {
      throw _bacaError(response.statusCode, response.body);
    }
  }

  // ---------- Auth ----------

  static Future<void> login(String email, String password) async {
    final response = await _kirim(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    _simpanSesi(_bacaSukses(response, 200));
  }

  static Future<void> register({
    required String nama,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _kirim(
      'POST',
      '/auth/register',
      body: {'nama': nama, 'email': email, 'password': password, 'role': role},
    );
    _simpanSesi(_bacaSukses(response, 201));
  }
}
