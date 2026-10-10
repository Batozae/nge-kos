import '../models/kost.dart';

// Single Source of Truth untuk data dummy kost yang ditampilkan di Home, Filter, dan Favorit
final List<Kost> dummyKostList = [
  const Kost(
    id: '1',
    nama: 'Kost Melati Asri',
    alamat: 'Jl. Ketintang No. 12, Surabaya',
    harga: 850000,
    fasilitas: ['WiFi', 'AC', 'Kamar Mandi Dalam'],
    imageUrl: 'assets/images/kost_melati.jpg',
    mapsUrl: 'https://maps.google.com/?q=-7.322,112.729',
    whatsappNumber: '6281234567890',
    status: KostStatus.tersedia,
  ),
  const Kost(
    id: '2',
    nama: 'Kost Griya Ayu',
    alamat: 'Jl. Gebang Putih No. 5, Surabaya',
    harga: 650000,
    fasilitas: ['WiFi', 'Kamar Mandi Luar'],
    imageUrl: 'assets/images/kost_griya.jpg',
    mapsUrl: 'https://maps.google.com/?q=-7.281,112.797',
    whatsappNumber: '6281234567891',
    status: KostStatus.hampirPenuh,
  ),
  const Kost(
    id: '3',
    nama: 'Kost Anggrek Residence',
    alamat: 'Jl. Kertajaya No. 88, Surabaya',
    harga: 1200000,
    fasilitas: ['WiFi', 'AC', 'Laundry', 'Kamar Mandi Dalam'],
    imageUrl: 'assets/images/kost_anggrek.jpg',
    mapsUrl: 'https://maps.google.com/?q=-7.278,112.769',
    whatsappNumber: '6281234567892',
    status: KostStatus.penuh,
  ),
];
