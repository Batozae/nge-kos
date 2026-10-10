import 'package:flutter/foundation.dart';

import '../models/kost.dart';
import 'api_service.dart';
import 'session_store.dart';

class FavoritStore {
  // Daftar id kost favorit. Widget mendengarkan perubahan nilai ini.
  static final ValueNotifier<Set<String>> ids = ValueNotifier<Set<String>>({});

  // Mengambil dari server, menyimpan id-nya, dan mengembalikan daftar kostnya
  static Future<List<Kost>> muatDaftar() async {
    final daftar = await ApiService.fetchFavorit();
    ids.value = daftar.map((k) => k.id).toSet();
    return daftar;
  }

  // Versi tanpa error ke luar, untuk dipanggil di latar belakang
  static Future<void> muat() async {
    try {
      await muatDaftar();
    } catch (e) {
      debugPrint('Gagal memuat favorit: $e');
    }
  }

  // Dipanggil setelah login atau daftar berhasil
  static void sinkron() {
    final user = SessionStore.user;
    if (user == null || user.isPemilik) {
      ids.value = {};
    } else {
      muat();
    }
  }

  // Ubah status favorit: tampilan langsung berubah, dibatalkan jika server gagal
  static Future<void> toggle(String kostId) async {
    final sebelumnya = ids.value;
    final sudahFavorit = sebelumnya.contains(kostId);

    ids.value = sudahFavorit
        ? ({...sebelumnya}..remove(kostId))
        : {...sebelumnya, kostId};

    try {
      if (sudahFavorit) {
        await ApiService.hapusFavorit(kostId);
      } else {
        await ApiService.tambahFavorit(kostId);
      }
    } catch (_) {
      ids.value = sebelumnya;
      rethrow;
    }
  }
}
