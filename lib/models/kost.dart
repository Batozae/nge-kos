enum KostStatus { tersedia, hampirPenuh, penuh }

KostStatus _statusDariApi(String nilai) {
  switch (nilai) {
    case 'tersedia':
      return KostStatus.tersedia;
    case 'hampir_penuh':
      return KostStatus.hampirPenuh;
    case 'penuh':
      return KostStatus.penuh;
    default:
      throw FormatException('Status kost tidak dikenal: $nilai');
  }
}

class Kost {
  final String id;
  final String nama;
  final String alamat;
  final int harga; // per bulan, dalam rupiah
  final List<String> fasilitas;
  final String imageUrl;
  final String mapsUrl;
  final String whatsappNumber;
  final KostStatus status;

  // Field baru dari kontrak API (bernilai bawaan agar kode lama tetap jalan)
  final String? patokan;
  final String kategoriPenyewa; // 'putra' | 'putri' | 'campur'
  final String ukuranKamar;
  final int jumlahKamarTotal;
  final int jumlahKamarKosong;

  const Kost({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.harga,
    required this.fasilitas,
    required this.imageUrl,
    required this.mapsUrl,
    required this.whatsappNumber,
    required this.status,
    this.patokan,
    this.kategoriPenyewa = 'campur',
    this.ukuranKamar = '-',
    this.jumlahKamarTotal = 0,
    this.jumlahKamarKosong = 0,
  });

  factory Kost.fromJson(Map<String, dynamic> json) {
    return Kost(
      id: json['id'] as String,
      nama: json['nama'] as String,
      alamat: json['alamat'] as String,
      harga: json['harga'] as int,
      fasilitas: (json['fasilitas'] as List).cast<String>(),
      imageUrl: (json['imageUrl'] as String?) ?? '',
      mapsUrl: json['mapsUrl'] as String,
      whatsappNumber: json['whatsappNumber'] as String,
      status: _statusDariApi(json['status'] as String),
      patokan: json['patokan'] as String?,
      kategoriPenyewa: json['kategoriPenyewa'] as String,
      ukuranKamar: json['ukuranKamar'] as String,
      jumlahKamarTotal: json['jumlahKamarTotal'] as int,
      jumlahKamarKosong: json['jumlahKamarKosong'] as int,
    );
  }
}
