# Nge-Kos

Aplikasi Flutter pencari kost (peran Pencari Kos dan Pemilik Kos). Mata kuliah Pemrograman Aplikasi Mobile.

## Repositori terkait

- Backend API: https://github.com/Batozae/nge-kos-api
- Tugas pertama (desain Stateless, dibekukan): https://github.com/Batozae/nge-kos-stateless-design

## Menjalankan

1. Jalankan backend lebih dulu (lihat README repo `nge-kos-api`); server di http://localhost:3000
2. `flutter pub get`
3. `flutter run -d chrome`

Mengganti alamat server tanpa mengubah kode:
`flutter run -d chrome --dart-define=API_BASE_URL=http://alamat-server`
(Android emulator memakai `http://10.0.2.2:3000`)

## Dokumentasi

Ringkasan proyek, kontrak API, aturan kode, dan daftar tugas lanjutan ada di folder `docs/`.
Baca `docs/ringkasan-proyek-nge-kos-tahap-integrasi-api.md` lebih dulu.

# nge_kos

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
