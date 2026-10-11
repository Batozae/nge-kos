# Ringkasan Proyek: Aplikasi "Nge-Kos" — Mata Kuliah Pemrograman Aplikasi Mobile

Sebagian isi diperbarui oleh dokumen 3 (integrasi API); bila bertentangan, dokumen 3 yang berlaku.

## 1. Konteks Tugas

- Mata kuliah: Pemrograman Aplikasi Mobile (PAM), menggunakan Dart + Flutter.
- Flutter sudah terinstal di VSCode.
- Tugas kelompok pertama:
  - Membuat desain 8-10 halaman bersifat **stateless**.
  - Tema bebas, asal **tidak mereplikasi aplikasi yang sudah ada**.
  - Setiap halaman harus sudah **terhubung dengan routing**.
  - Source code akan di-upload ke **GitHub**.
  - Kelompok akan presentasi menjelaskan source code, video di-upload ke **YouTube**.
- Kelompok meyakini aplikasi ini akan **dikembangkan menjadi proyek akhir** semester.
- Kelompok belum tahu roadmap materi kelas berikutnya (belum tentu backend/database diajarkan tepat waktu) — jadi strategi pengembangan diarahkan untuk aman dari sisi dependency teknis di awal.

## 2. Pemilihan Aplikasi & Rencana Pengembangan

- Tema akhir yang dipilih: **aplikasi pencari kost**, bernama **"Nge-Kos"**.
- Alasan pemilihan (dibanding alternatif seperti aplikasi berita atau manajemen keuangan): potensi fitur lebih kaya untuk berkembang jadi proyek akhir, sekaligus bisa berjalan penuh dengan data lokal/dummy dulu tanpa perlu menunggu materi backend.
- Konsep inti: aplikasi berfungsi sebagai **penjembatan** antara pencari kos dan pemilik jasa — bukan platform transaksi penuh.
  - Chat: **redirect ke WhatsApp** pemilik kos, bukan chat in-app (menghindari kebutuhan backend real-time di fase awal).
  - Lokasi: cukup berupa **link ke Google Maps**, bukan integrasi Maps SDK penuh.
  - Pembayaran: **di luar aplikasi**, tidak ditangani sistem.
- Rencana jangka panjang (untuk pengembangan proyek akhir, belum masuk fase desain 10 halaman saat ini):
  - Role tambahan: **Pemilik Laundry** dan **Jasa Pembersihan Kamar Kos**, masing-masing bisa login dan posting listing sendiri.
  - Role **penyedia jasa galon air** sempat dipertimbangkan tapi **diputuskan tidak dipakai**.
  - Catatan penting: begitu role posting (laundry/cleaning) ditambahkan, aplikasi **wajib punya backend** (misal Firebase Firestore + Auth) sejak awal implementasi fitur tersebut — tidak bisa lagi mengandalkan data lokal, karena listing harus terlihat oleh semua pencari kos.
- **Untuk fase desain saat ini, disepakati baru 2 role**: **Pencari Kos** dan **Pemilik Kos**. Semua elemen UI (filter, feed, favorit) untuk fase ini sengaja dibuat konsisten hanya membahas kost — tanpa jejak kategori laundry/cleaning — supaya tidak ada fitur yang terlihat "setengah jadi".

## 3. Brand Identity

**Nama aplikasi:** Nge-Kos

- Versi teknis untuk kebutuhan package/nama project: `nge_kos` (snake_case) atau `NgeKos` (PascalCase).

**Warna Primer:** Petrol Blue `#1B4965`
**Warna Sekunder:** Oranye terracotta `#EE964B` (untuk CTA seperti tombol booking/redirect WhatsApp)
_(Catatan: warna hijau sengaja dihindari karena itu warna identitas Mamikos, kompetitor besar di kategori yang sama)_

**Warna Netral:**

- Background: `#FAF9F6` (off-white)
- Teks utama: `#1A1A1A`
- Teks sekunder/label: `#6B7280`

**Warna Status (untuk badge ketersediaan kost, dsb):**

- Tersedia: `#4C956C`
- Hampir penuh: `#EE964B`
- Penuh: `#C1121F`

**Tipografi:**

- Font Primer (judul/heading): **Poppins**
- Font Sekunder (body text/deskripsi): **Inter** atau **Nunito Sans**
- Sumber: Google Fonts (via package `google_fonts` di Flutter/pub.dev)

**Style Guide UI Lainnya:**

- Border radius agak besar (12-16px) untuk card kost — kesan ramah, tidak kaku.
- Ikon bergaya rounded/outline, bukan sharp/filled solid.
- Spacing lega, tidak padat — karena info kost (harga, fasilitas, lokasi) butuh hierarki visual jelas.

## 4. Fitur & Logika Fungsional

- Pencarian kos dengan filter (harga, fasilitas, area, dll).
- Informasi detail kos.
- Kos yang ditandai/favorit (disimpan lokal per device, misal via `shared_preferences`/`hive` — tidak perlu sinkron server untuk fase 2-role ini).
- Komunikasi dengan pemilik kos: redirect ke WhatsApp (pakai `url_launcher` ke `wa.me/nomor`), bukan chat in-app.
- Lokasi: link ke Google Maps (`url_launcher`), bukan SDK Maps penuh.
- Pembayaran: sepenuhnya di luar aplikasi.
- Role **Pemilik Kos** bisa membuat dan mengelola listing kost sendiri:
  - Halaman posting kost juga berfungsi sebagai halaman **edit/kelola listing yang sudah ada** (bukan cuma form kosong sekali pakai) — pemilik bisa punya lebih dari satu listing.
- Role **Pencari Kos** hanya bisa mencari, melihat detail, dan memfavoritkan — tidak bisa upload/posting apa pun.
- Karena ada 2 role dengan login dan listing yang harus terlihat pencari lain, aplikasi pada fase ini **sudah butuh backend** (kemungkinan Firebase Firestore + Auth) untuk menyimpan data user (dengan field role) dan data listing kost.

## 5. Daftar 10 Halaman yang Disepakati (Fase Desain Saat Ini)

1. Splash Screen
2. Onboarding
3. Login
4. Register (dengan pilihan role: Pencari Kos / Pemilik Kos)

**Sebagai Pencari Kos:**

5. Home (feed listing kost)
6. Hasil Pencarian & Filter (atribut kost saja — harga, fasilitas, area)
7. Detail Kost
8. Favorit (kost yang ditandai)

**Sebagai Pemilik Kos:**

9. Halaman Posting/Edit Kost (form posting sekaligus kelola listing yang sudah ada)
10. Profil Pemilik Kos

---

_Catatan: dokumen ini merangkum diskusi perencanaan tema, brand identity, fitur, dan struktur halaman. Detail implementasi teknis (skema Firestore, security rules, komponen UI per halaman) belum dibahas mendalam dan bisa jadi topik lanjutan di sesi berikutnya._
