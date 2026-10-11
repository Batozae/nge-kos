# Ringkasan Sesi — Proyek "Nge-Kos" (Lanjutan)

Sebagian isi diperbarui oleh dokumen 3 (integrasi API); bila bertentangan, dokumen 3 yang berlaku.

> Dokumen ini dibuat untuk dibawa ke sesi percakapan baru dengan Claude, sebagai pengganti sesi sebelumnya yang membahas keseluruhan proses desain 10 halaman aplikasi Nge-Kos.

## 1. Status Saat Ini

**Seluruh 10 halaman desain sudah selesai dibuat** (Splash, Onboarding, Login, Register, Home, Hasil Pencarian & Filter, Detail Kost, Favorit, Posting/Edit Kost, Profil Pemilik). Fase yang tersisa: **persiapan presentasi** (video dijelaskan source code untuk di-upload ke YouTube) dan **push final ke GitHub**.

**Ada 1 masalah belum terselesaikan** di akhir sesi sebelumnya: error di `app.dart` pada bagian route `SearchFilterScreen` dan `FavoritScreen`, tapi **teks error persisnya belum sempat dikirim** oleh pengguna sebelum sesi diganti. Kemungkinan penyebab yang perlu dicek di sesi baru (urut prioritas):

1. Baris import `search_filter_screen.dart`/`favorit_screen.dart` di `app.dart` — cek apakah path/nama file persis sesuai lokasi file di project.
2. Isi file `search_filter_screen.dart`/`favorit_screen.dart` yang benar-benar ter-save di project — kemungkinan berbeda dari kode yang sudah didiskusikan sebelumnya karena typo saat paste.
3. Nama class di file tersebut — pastikan persis `SearchFilterScreen` dan `FavoritScreen` (case-sensitive).

Kalau lanjut ke sesi baru, **sertakan teks error lengkap + isi file yang bermasalah** supaya bisa langsung didiagnosis, bukan ditebak.

## 2. Konteks Proyek

- Mata kuliah Pemrograman Aplikasi Mobile (Flutter + Dart), tugas kelompok pertama.
- Requirement: 10 halaman **stateless** (`StatelessWidget` murni, tidak boleh `StatefulWidget`), semua terhubung routing.
- Tema: aplikasi pencari kost "Nge-Kos" — 2 role: **Pencari Kos** dan **Pemilik Kos**.
- Fase ini pakai **dummy data**, belum ada backend. Backend (kemungkinan Firebase Firestore + Auth) baru dibutuhkan di fase **proyek akhir semester**, saat role Laundry/Cleaning ditambahkan dan listing harus terlihat lintas-user secara real.
- Fitur di luar aplikasi: chat redirect ke WhatsApp (`url_launcher` ke `wa.me/`), lokasi redirect ke Google Maps (`url_launcher`), pembayaran di luar sistem.
- Anggota kelompok mengerjakan halaman berbeda-beda dengan bantuan AI masing-masing — konsistensi kode dijaga lewat dokumen ringkasan teknis yang sudah dibagikan ke tim sebelumnya.

## 3. Struktur Folder `lib/` (Final)

```
lib/
├─ main.dart
├─ app.dart
├─ theme/
│   └─ app_theme.dart
├─ routes/
│   └─ app_routes.dart
├─ models/
│   └─ kost.dart
├─ data/
│   └─ dummy_kost.dart
├─ screens/
│   ├─ splash_screen.dart
│   ├─ onboarding_screen.dart
│   ├─ auth/
│   │   ├─ login_screen.dart
│   │   └─ register_screen.dart
│   ├─ pencari_kos/
│   │   ├─ home_screen.dart
│   │   ├─ search_filter_screen.dart
│   │   ├─ detail_kost_screen.dart
│   │   └─ favorit_screen.dart
│   └─ pemilik_kos/
│       ├─ posting_edit_kost_screen.dart
│       └─ profil_pemilik_screen.dart
└─ widgets/
    ├─ kost_card.dart
    └─ primary_button.dart
```

## 4. Codebase Inti (Penting Untuk Dipahami di Sesi Baru)

### `theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF1B4965);   // Petrol Blue
  static const secondary = Color(0xFFEE964B); // Terracotta (CTA)
  static const background = Color(0xFFFAF9F6);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const statusAvailable = Color(0xFF4C956C);
  static const statusAlmostFull = Color(0xFFEE964B);
  static const statusFull = Color(0xFFC1121F);
}

ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    secondary: AppColors.secondary,
  ),
  textTheme: TextTheme(
    headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary),
    bodySmall: GoogleFonts.inter(color: AppColors.textSecondary),
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
);
```

### `routes/app_routes.dart`

```dart
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const searchFilter = '/search-filter';
  static const detailKost = '/detail-kost';
  static const favorit = '/favorit';
  static const postingEditKost = '/posting-edit-kost';
  static const profilPemilik = '/profil-pemilik';
}
```

### `models/kost.dart`

```dart
enum KostStatus { tersedia, hampirPenuh, penuh }

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
  });
}
```

**Catatan penting:** form `PostingEditKostScreen` (dibuat anggota lain) punya field seperti _Kategori Penyewa_, _Ukuran Kamar_, _Jumlah Kamar_ yang **tidak ada** di model ini. Belum masalah sekarang (belum ada logic simpan), tapi kalau nanti disambungkan ke penyimpanan data beneran, field itu tidak akan punya tempat kecuali model ini diperluas — perlu didiskusikan ke tim.

### `data/dummy_kost.dart` — single source of truth untuk semua dummy data

```dart
import '../models/kost.dart';

final List<Kost> dummyKostList = [
  const Kost(
    id: '1', nama: 'Kost Melati Asri', alamat: 'Jl. Ketintang No. 12, Surabaya',
    harga: 850000, fasilitas: ['WiFi', 'AC', 'Kamar Mandi Dalam'],
    imageUrl: 'https://picsum.photos/seed/kost1/400/300',
    mapsUrl: 'https://maps.google.com/?q=-7.322,112.729',
    whatsappNumber: '6281234567890', status: KostStatus.tersedia,
  ),
  const Kost(
    id: '2', nama: 'Kost Griya Ayu', alamat: 'Jl. Gebang Putih No. 5, Surabaya',
    harga: 650000, fasilitas: ['WiFi', 'Kamar Mandi Luar'],
    imageUrl: 'https://picsum.photos/seed/kost2/400/300',
    mapsUrl: 'https://maps.google.com/?q=-7.281,112.797',
    whatsappNumber: '6281234567891', status: KostStatus.hampirPenuh,
  ),
  const Kost(
    id: '3', nama: 'Kost Anggrek Residence', alamat: 'Jl. Kertajaya No. 88, Surabaya',
    harga: 1200000, fasilitas: ['WiFi', 'AC', 'Laundry', 'Kamar Mandi Dalam'],
    imageUrl: 'https://picsum.photos/seed/kost3/400/300',
    mapsUrl: 'https://maps.google.com/?q=-7.278,112.769',
    whatsappNumber: '6281234567892', status: KostStatus.penuh,
  ),
];
```

Dipakai ulang di: Home, Hasil Pencarian & Filter, Favorit (subset), dan disimulasikan sebagai "listing milik pemilik" di Profil Pemilik.

### `widgets/kost_card.dart` & `widgets/primary_button.dart`

Dua widget reusable inti — `KostCard` menerima 1 objek `Kost` + `onTap` callback, dipakai di semua halaman yang menampilkan daftar kost. `PrimaryButton` membungkus `ElevatedButton` dengan style CTA standar (warna secondary/terracotta, radius 14). **Catatan konsistensi:** Splash & Onboarding masih pakai `ElevatedButton` manual (dibuat sebelum `PrimaryButton` ada) — belum sempat di-refactor, tapi tidak mendesak.

### `main.dart`

```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const NgeKosApp());
}
```

### `app.dart` (versi terakhir, ada error belum terdiagnosis — lihat bagian 1)

```dart
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/pencari_kos/home_screen.dart';
import 'screens/pencari_kos/search_filter_screen.dart';
import 'screens/pemilik_kos/posting_edit_kost_screen.dart';
import 'screens/pemilik_kos/profil_pemilik_screen.dart';
import 'screens/pencari_kos/favorit_screen.dart';
import 'screens/pencari_kos/detail_kost_screen.dart';
import 'models/kost.dart';

class NgeKosApp extends StatelessWidget {
  const NgeKosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nge-Kos',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.searchFilter: (context) => const SearchFilterScreen(),
        AppRoutes.favorit: (context) => const FavoritScreen(),
        AppRoutes.profilPemilik: (context) => const ProfilPemilikScreen(),
        AppRoutes.postingEditKost: (context) {
          final kost = ModalRoute.of(context)!.settings.arguments as Kost?;
          return PostingEditKostScreen(kost: kost);
        },
        AppRoutes.detailKost: (context) {
          final kost = ModalRoute.of(context)!.settings.arguments as Kost;
          return DetailKostScreen(kost: kost);
        },
      },
    );
  }
}
```

## 5. Logika Fungsional Penting (Konvensi yang Wajib Dijaga)

1. **Semua screen `StatelessWidget`** — requirement tugas eksplisit, tidak boleh dilanggar demi kemudahan (misal auto-redirect splash, toggle role selector, stepper form — semua sengaja dibuat versi statis untuk menghindari kebutuhan `StatefulWidget`).

2. **Pola passing data ke Detail Kost — sudah baku, jangan diubah:** `Navigator.pushNamed(context, AppRoutes.detailKost, arguments: kost)`, diterima di `app.dart` lewat `ModalRoute.of(context)!.settings.arguments as Kost` (non-nullable — sengaja, karena Detail Kost tidak punya mode kosong). Pola sama juga dipakai untuk `postingEditKost`, tapi di sana `as Kost?` (nullable, karena ada mode "tambah baru" tanpa data).

3. **`url_launcher` dipakai di 2 tempat dengan pola sama:** Detail Kost (tombol WhatsApp ke `wa.me/<whatsappNumber>`, tombol lokasi ke `kost.mapsUrl`). Belum ada error handling kalau `launchUrl` gagal.

4. **Search bar di Home = trigger navigasi, bukan filter di tempat** — filtering beneran (walau masih statis/tampilan saja) ada di Hasil Pencarian & Filter, supaya logic tidak terduplikasi di 2 halaman.

5. **Bottom navigation Home ↔ Favorit** pakai `Navigator.canPop()` untuk kembali ke Home yang sudah ada di stack (bukan selalu `pushReplacementNamed`, supaya tidak numpuk instance Home).

6. **Ikon profil di Home mengarah ke Profil Pemilik** — ini shortcut khusus untuk kemudahan presentasi/demo, bukan alur asli (secara role, Pencari Kos seharusnya tidak menuju Profil Pemilik). Perlu disebutkan saat presentasi kalau ditanya dosen.

7. **Risiko crash yang perlu dicek sebelum presentasi:**
   - `AssetImage('assets/images/pemilik.jpg')` di Profil Pemilik — pastikan file asset benar-benar ada dan sudah didaftarkan di `pubspec.yaml` (`flutter: assets: - assets/images/`), kalau belum akan crash.
   - `.withOpacity()` yang deprecated sudah diganti ke `.withValues(alpha:)` di sebagian besar kode — cek ulang tidak ada sisa `.withOpacity()` yang lolos sebelum submit (cukup warning, bukan error, tapi lebih rapi kalau bersih).

8. **Dependency (`pubspec.yaml`):** `google_fonts`, `url_launcher` — cukup untuk seluruh 10 halaman fase ini, tidak perlu tambahan state management (`provider`/`riverpod`/`bloc`) maupun `shared_preferences`/`hive` karena tidak ada logic simpan-baca data nyata di fase desain ini.

## 6. Rencana Setelah Fase Ini (Bukan Bagian Tugas Sekarang)

- Fase proyek akhir: tambah role Pemilik Laundry & Jasa Pembersihan Kamar Kos, masing-masing bisa posting listing sendiri.
- Begitu ada fitur posting lintas-role, backend (kemungkinan Firebase Firestore + Auth) wajib masuk — `data/dummy_kost.dart` akan digantikan `service`/`repository` layer yang fetch dari Firestore, tapi `widgets/kost_card.dart` **tidak perlu diubah** karena sudah didesain reusable (cuma terima objek `Kost`, tidak tahu sumber datanya).
- Login/Register baru butuh logic asli (`FirebaseAuth`) di fase itu.
