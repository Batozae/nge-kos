# Ringkasan Sesi — Proyek "Nge-Kos": Integrasi REST API (Dokumen 3 dari 3)

> Dibuat 10 Oktober 2026. Dokumen ini dibuat untuk dibawa ke sesi percakapan baru (dengan Claude atau AI lain) dan untuk dibaca anggota kelompok. Isinya merangkum seluruh pekerjaan backend + integrasi Flutter ke API yang dikerjakan setelah dua ringkasan sebelumnya, keputusan desain beserta alasannya, batasan yang diketahui, dan 4 pekerjaan lanjutan untuk anggota lain.

---

## 0. Cara memakai dokumen ini

### 0.1 Peta dokumen

| #   | Dokumen                                              | Isi                                                                                 | Status                                                                        |
| --- | ---------------------------------------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| 1   | `ringkasan-proyek-nge-kos(tahap-perencanaan).md`     | Konteks tugas, tema, brand identity (warna, font), daftar 10 halaman                | Brand dan daftar halaman **masih berlaku**. Bagian backend/Firebase **usang** |
| 2   | `ringkasan-proyek-nge-kos(tahap-eksekusi-desain).md` | Kode 10 halaman Stateless dengan data dummy, konvensi desain                        | Sebagian **digantikan** dokumen ini (lihat 0.2)                               |
| 3   | **Dokumen ini**                                      | Backend Express + SQLite, kontrak API, integrasi Flutter, keputusan, tugas lanjutan | **Sumber kebenaran terbaru**                                                  |

**Aturan prioritas bila ada pertentangan:** kode sumber yang sebenarnya > dokumen ini > dokumen 2 > dokumen 1. Dokumen bisa tertinggal dari kode, jadi bila ragu, minta kode aslinya.

### 0.2 Hal di dokumen sebelumnya yang sekarang SUDAH BERUBAH

| Di dokumen lama                                            | Sekarang                                                                                                                                                                                  |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Backend akan memakai Firebase (Firestore + Auth)           | **Dilarang dosen (BaaS).** Dipakai backend sendiri: Express (Node.js) + SQLite. Dosen kemudian mengonfirmasi **MySQL via XAMPP/phpMyAdmin**; migrasi belum dikerjakan (tugas lanjutan #1) |
| Semua 10 layar wajib `StatelessWidget`                     | Layar yang memanggil API atau membaca input kini **`StatefulWidget`**. Layar lain tetap Stateless. Branch `main` di repo Flutter masih versi Stateless untuk tugas yang dinilai           |
| Data dari `data/dummy_kost.dart`                           | Data dari API. `dummy_kost.dart` **tidak dipakai layar mana pun lagi** (file dibiarkan, jangan dihapus sebelum penilaian selesai)                                                         |
| Favorit disimpan lokal (`shared_preferences`/`hive`)       | Favorit disimpan **di database** lewat endpoint `/favorit`                                                                                                                                |
| `imageUrl` dummy berupa URL `picsum.photos`                | Seed memakai **path asset** (`assets/images/kost_melati.jpg`, dst). Kost buatan pemilik tidak punya gambar (tampil placeholder) sampai fitur upload dibuat                                |
| Model `Kost` punya 9 field                                 | Ditambah 5 field (lihat bagian 5.5)                                                                                                                                                       |
| "Tidak perlu state management atau penyimpanan lokal"      | Ada tiga penyimpan sederhana tanpa paket tambahan: `SessionStore`, `FavoritStore` (memori), plus paket `http`                                                                             |
| Login dan Register hanya tombol navigasi                   | Terhubung API; menyimpan token di memori; mengarahkan berdasarkan peran                                                                                                                   |
| Error `app.dart` yang belum terdiagnosis (dok 2, bagian 1) | Tidak pernah dikonfirmasi eksplisit di sesi ini; aplikasi berjalan di Chrome sehingga kemungkinan besar sudah teratasi. Verifikasi bila muncul lagi                                       |

---

## 1. Status pekerjaan

| Tahap   | Isi                                                                   | Status     |
| ------- | --------------------------------------------------------------------- | ---------- |
| 0       | Setup environment Windows (Node.js LTS, npm, repo, Thunder Client)    | ✅ Selesai |
| 1       | Kontrak API (`docs/API_CONTRACT.md`)                                  | ✅ Selesai |
| 2       | Kerangka server Express + SQLite + seed                               | ✅ Selesai |
| 3       | `GET /kost` (filter, urutan) dan `GET /kost/:id`                      | ✅ Selesai |
| 4       | Auth: register, login, JWT, middleware peran, `GET /auth/me`          | ✅ Selesai |
| 5       | Endpoint pemilik: daftar milik sendiri, `POST`, `PUT`, `DELETE /kost` | ✅ Selesai |
| 6       | Kontrak final; koneksi Flutter web (Chrome) ke API                    | ✅ Selesai |
| 7a      | Home dan Detail terhubung; widget gambar bersama `KostImage`          | ✅ Selesai |
| 7b      | Login dan Register terhubung; sesi login                              | ✅ Selesai |
| 7c      | Profil Pemilik dan form Posting/Edit/Hapus terhubung                  | ✅ Selesai |
| Favorit | Tabel + endpoint `/favorit`; tombol hati; layar Favorit               | ✅ Selesai |
| 7d      | Hasil Pencarian & Filter terhubung (cari, 4 panel filter, urutan)     | ✅ Selesai |

**Belum dikerjakan:** `README.md` repo API; ekspor koleksi Thunder Client (opsional; fitur koleksi berbayar di versi gratis, alternatif: ekstensi REST Client dengan file `.http`); **4 tugas lanjutan di bagian 8**.

**Layar yang tidak butuh API dan tidak diubah:** Splash, Onboarding.

---

## 2. Cara menjalankan

**Prasyarat:** Node.js (versi LTS), Flutter SDK, VSCode, Git. Ekstensi Thunder Client (versi gratis cukup untuk pengujian per request).

### Backend (`nge-kos-api`)

```
npm install
npm run dev        # menjalankan server di http://localhost:3000 (node --watch)
```

- Buat file `.env` (tidak boleh di-commit): `PORT=3000` dan `JWT_SECRET=<teks acak panjang, minimal 32 karakter>`. Server berhenti dengan pesan error bila `JWT_SECRET` kosong.
- Database `nge-kos.db` dibuat otomatis di root proyek saat pertama jalan, beserta seed (hanya jika tabel `users` kosong). **Reset data:** hentikan server, hapus `nge-kos.db`, jalankan ulang.
- Cek hidup: `GET http://localhost:3000/health` → `{"status":"ok"}`.

### Flutter (`nge_kos`)

```
flutter pub get
flutter run -d chrome
```

- Alamat server dapat diganti tanpa mengubah kode: `flutter run -d chrome --dart-define=API_BASE_URL=https://alamat-server`. Bawaan: `http://localhost:3000`.
- **Android emulator** tidak bisa memakai `localhost`; pakai `--dart-define=API_BASE_URL=http://10.0.2.2:3000`. HP fisik memerlukan IP laptop di jaringan yang sama.
- Server harus berjalan lebih dulu, di terminal terpisah.

### Akun dan data uji (khusus pengembangan lokal)

| Akun           | Email                  | Sandi         | Peran   |
| -------------- | ---------------------- | ------------- | ------- |
| Pemilik contoh | `pemilik@nge-kos.test` | `password123` | pemilik |
| Pencari contoh | `pencari@nge-kos.test` | `password123` | pencari |

Seed kost (semua milik "Pemilik Contoh"):

| id  | Nama                   | Alamat                           | Kategori | Kamar total/kosong | Harga   | Fasilitas                            | Gambar                         | WhatsApp      | Status       |
| --- | ---------------------- | -------------------------------- | -------- | ------------------ | ------- | ------------------------------------ | ------------------------------ | ------------- | ------------ |
| 1   | Kost Melati Asri       | Jl. Ketintang No. 12, Surabaya   | putri    | 10/6               | 850000  | WiFi, AC, Kamar Mandi Dalam          | assets/images/kost_melati.jpg  | 6281234567890 | tersedia     |
| 2   | Kost Griya Ayu         | Jl. Gebang Putih No. 5, Surabaya | campur   | 8/2                | 650000  | WiFi, Kamar Mandi Luar               | assets/images/kost_griya.jpg   | 6281234567891 | hampir_penuh |
| 3   | Kost Anggrek Residence | Jl. Kertajaya No. 88, Surabaya   | putra    | 12/0               | 1200000 | WiFi, AC, Laundry, Kamar Mandi Dalam | assets/images/kost_anggrek.jpg | 6281234567892 | penuh        |

### Catatan Windows

- Jika PowerShell menolak menjalankan skrip npm: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`, atau pakai Command Prompt.
- Jalankan perintah Git satu per satu (`&&` tidak selalu bekerja di PowerShell lama).
- Nama file seperti `.env` dan `.gitignore` harus persis; Windows sering menambah `.txt` bila dibuat lewat Notepad.

---

## 3. Backend (`nge-kos-api`)

### 3.1 Stack

Node.js + Express, `better-sqlite3` (sinkron), `jsonwebtoken`, `bcryptjs`, `cors`, `dotenv`. JavaScript biasa (CommonJS `require`), tanpa TypeScript. Skrip: `start` (`node src/index.js`), `dev` (`node --watch src/index.js`).

### 3.2 Struktur dan tanggung jawab file

```
nge-kos-api/
├─ .env                  (PORT, JWT_SECRET; tidak di-commit)
├─ .gitignore            (node_modules, .env, *.db, *.db-wal, *.db-shm)
├─ package.json
├─ docs/API_CONTRACT.md  (kontrak lengkap; ringkasannya di bagian 4)
└─ src/
   ├─ index.js
   ├─ db.js
   ├─ middleware/auth.js
   ├─ routes/auth.js
   ├─ routes/kost.js
   ├─ routes/owner.js
   ├─ routes/favorit.js
   └─ utils/
      ├─ http.js
      └─ kost.js
```

| File                     | Tanggung jawab                                                                                                                                                                               |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/index.js`           | Memuat `.env`, memeriksa `JWT_SECRET`, `cors()` + `express.json()`, `/health`, mendaftarkan route (`/auth`, `/kost`, `/owner`, `/favorit`), penanganan 404 JSON dan error 500/400-JSON-rusak |
| `src/db.js`              | Koneksi SQLite (`WAL`, `foreign_keys = ON`), pembuatan tabel (`CREATE TABLE IF NOT EXISTS`), seed. Mengekspor objek `db`                                                                     |
| `src/middleware/auth.js` | `requireAuth` (membaca `Authorization: Bearer`, mengisi `req.user = {id, role}`), `requireRole(role)`                                                                                        |
| `src/routes/auth.js`     | `POST /auth/register`, `POST /auth/login`, `GET /auth/me`                                                                                                                                    |
| `src/routes/kost.js`     | `GET /kost` (filter), `GET /kost/:id`, `POST /kost`, `PUT /kost/:id`, `DELETE /kost/:id`                                                                                                     |
| `src/routes/owner.js`    | `GET /owner/kost`                                                                                                                                                                            |
| `src/routes/favorit.js`  | `GET /favorit`, `PUT /favorit/:kostId`, `DELETE /favorit/:kostId` (semua khusus pencari; ada pemeriksaan bahwa akun di token masih ada)                                                      |
| `src/utils/http.js`      | `kirimError(res, status, code, message)`: satu-satunya cara membuat respons error                                                                                                            |
| `src/utils/kost.js`      | `hitungStatus`, `formatKost`/`formatDaftarKost` (baris DB → objek JSON kontrak), `ambilFasilitas`, `FASILITAS_VALID`, `validasiKost`, `ambilKostById`                                        |

### 3.3 Skema database (SQLite)

```sql
users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('pencari','pemilik'))
)
kost (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_id INTEGER NOT NULL REFERENCES users(id),
  nama TEXT NOT NULL, alamat TEXT NOT NULL, patokan TEXT,
  maps_url TEXT NOT NULL,
  kategori_penyewa TEXT NOT NULL CHECK (kategori_penyewa IN ('putra','putri','campur')),
  ukuran_kamar TEXT NOT NULL,
  jumlah_kamar_total INTEGER NOT NULL, jumlah_kamar_kosong INTEGER NOT NULL,
  harga INTEGER NOT NULL, image_url TEXT, whatsapp_number TEXT NOT NULL
)
kost_fasilitas (
  kost_id INTEGER NOT NULL REFERENCES kost(id) ON DELETE CASCADE,
  nama TEXT NOT NULL,
  PRIMARY KEY (kost_id, nama)
)
favorit (
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kost_id INTEGER NOT NULL REFERENCES kost(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, kost_id)
)
```

`status` kost **tidak disimpan**; dihitung saat respons dibuat.

### 3.4 Konvensi backend (wajib dijaga)

1. **Semua respons error lewat `kirimError`** dengan bentuk `{ "error": { "code", "message" } }`.
2. **ID di JSON selalu string** (`"1"`), di database integer. Konversi ada di `formatKost`.
3. **Nama di database `snake_case`, nama di JSON `camelCase`.** Pemetaannya hanya di `utils/kost.js`.
4. **Nilai dari pengguna tidak boleh disambung ke teks SQL.** Selalu parameter terikat (`?`). `ORDER BY` memakai daftar putih (`URUTAN` di `routes/kost.js`) karena tidak bisa memakai `?`.
5. **`owner_id` dan `user_id` selalu dari token** (`req.user.id`), tidak pernah dari body.
6. **Aturan status** hanya didefinisikan di `hitungStatus` (satu tempat): kosong = 0 → `penuh`; `kosong * 4 <= total` → `hampir_penuh`; selain itu `tersedia`. Filter `status` pada `GET /kost` dilakukan di kode setelah query, bukan di SQL, supaya aturannya tidak terduplikasi.
7. **Validasi angka ketat:** `jumlahKamarTotal`, `jumlahKamarKosong`, `harga` harus **angka JSON**, bukan teks.
8. **Urutan middleware:** `cors()` dan `express.json()` sebelum route; penanganan 404 dan error paling akhir. Route baru wajib didaftarkan **di atas** penanganan 404.
9. `PUT /kost/:id` **mengganti seluruh data** (bukan sebagian): field opsional yang tidak dikirim menjadi kosong.
10. Urutan pemeriksaan `PUT`/`DELETE` kost: token (401) → peran (403) → kost ada (404) → milik sendiri (403) → isi body (400, hanya PUT).
11. Perubahan endpoint **wajib memperbarui `docs/API_CONTRACT.md`**.

---

## 4. Kontrak API (ringkas)

Base URL lokal `http://localhost:3000`. JSON. Auth: `Authorization: Bearer <token>` (JWT, berlaku 7 hari, isi: `id`, `role`).

**Bentuk respons:** objek tunggal `{ "data": {...} }`; daftar `{ "data": [...], "total": n }`; auth `{ "token", "user" }`; `DELETE`/`PUT favorit` sukses → 204 tanpa body.

**Objek User:** `{ id, nama, email, role }`

**Objek Kost:**

```json
{
  "id": "1",
  "nama": "Kost Melati Asri",
  "alamat": "Jl. Ketintang No. 12, Surabaya",
  "patokan": null,
  "mapsUrl": "https://maps.google.com/?q=-7.322,112.729",
  "kategoriPenyewa": "putri",
  "ukuranKamar": "3 x 4 m",
  "jumlahKamarTotal": 10,
  "jumlahKamarKosong": 6,
  "harga": 850000,
  "fasilitas": ["WiFi", "AC", "Kamar Mandi Dalam"],
  "imageUrl": "assets/images/kost_melati.jpg",
  "whatsappNumber": "6281234567890",
  "status": "tersedia"
}
```

`kategoriPenyewa`: `putra|putri|campur`. `status`: `tersedia|hampir_penuh|penuh` (dihitung server, tidak boleh dikirim klien). `patokan` dan `imageUrl` boleh `null`.

| Method | Path             | Akses                     | Sukses                       | Error                        |
| ------ | ---------------- | ------------------------- | ---------------------------- | ---------------------------- |
| GET    | /health          | publik                    | 200 `{status:"ok"}`          |                              |
| POST   | /auth/register   | publik                    | 201                          | 400, 409 EMAIL_TAKEN         |
| POST   | /auth/login      | publik                    | 200                          | 400, 401 INVALID_CREDENTIALS |
| GET    | /auth/me         | login                     | 200 `{data: User}`           | 401                          |
| GET    | /kost            | publik                    | 200 daftar                   | 400                          |
| GET    | /kost/:id        | publik                    | 200                          | 404                          |
| GET    | /owner/kost      | pemilik                   | 200 daftar                   | 401, 403                     |
| POST   | /kost            | pemilik                   | 201                          | 400, 401, 403                |
| PUT    | /kost/:id        | pemilik (pemilik listing) | 200                          | 400, 401, 403, 404           |
| DELETE | /kost/:id        | pemilik (pemilik listing) | 204                          | 401, 403, 404                |
| GET    | /favorit         | pencari                   | 200 daftar (terbaru di atas) | 401, 403                     |
| PUT    | /favorit/:kostId | pencari                   | 204 (idempoten)              | 401, 403, 404                |
| DELETE | /favorit/:kostId | pencari                   | 204 (idempoten)              | 401, 403, 404                |

**`POST /auth/register`:** body `nama`, `email`, `password` (8 sampai 72 karakter), `role`. Email dinormalkan (huruf kecil). Register langsung mengembalikan token (pengguna otomatis masuk).

**`GET /kost` (semua query opsional):** `q` (nama atau alamat), `area` (alamat), `hargaMin`, `hargaMax` (angka bulat), `fasilitas` (dipisah koma; harus memiliki **semua**; huruf besar/kecil diabaikan), `status`, `sort` (`harga_asc|harga_desc`; bawaan: urutan id).

**`POST`/`PUT /kost` body:** wajib `nama`, `alamat`, `mapsUrl` (diawali `http://` atau `https://`), `kategoriPenyewa`, `ukuranKamar`, `jumlahKamarTotal` (≥1), `jumlahKamarKosong` (0 sampai total), `harga` (>0), `whatsappNumber` (regex `^62\d{8,13}$`). Opsional: `patokan`, `imageUrl`, `fasilitas` (bawaan `[]`). Fasilitas yang diizinkan (10): WiFi, AC, Kamar Mandi Dalam, Kamar Mandi Luar, Kasur, Lemari, Meja Belajar, Laundry, Parkir Motor, Dapur Bersama.

**Kode error:**

| HTTP | code                | Arti                                                                          |
| ---- | ------------------- | ----------------------------------------------------------------------------- |
| 400  | VALIDATION_ERROR    | Input tidak valid (pesan menjelaskan field-nya, memakai nama field camelCase) |
| 401  | UNAUTHORIZED        | Header token tidak ada                                                        |
| 401  | INVALID_TOKEN       | Token salah/kedaluwarsa, atau akun di token tidak ada lagi                    |
| 401  | INVALID_CREDENTIALS | Email atau sandi salah (pesan sama untuk "email tidak ada" dan "sandi salah") |
| 403  | FORBIDDEN           | Peran salah, atau kost milik orang lain                                       |
| 404  | NOT_FOUND           | Kost atau endpoint tidak ditemukan                                            |
| 409  | EMAIL_TAKEN         | Email sudah terdaftar                                                         |
| 500  | INTERNAL_ERROR      | Kesalahan server                                                              |

---

## 5. Flutter (repo `nge_kos`, branch `feat/api-integration`)

### 5.1 File baru dan file yang berubah

| File                                                             | Status           | Peran                                                                                                                                          |
| ---------------------------------------------------------------- | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `lib/models/kost.dart`                                           | diubah           | +5 field, `Kost.fromJson`, `_statusDariApi` (melempar `FormatException` untuk status tak dikenal)                                              |
| `lib/models/app_user.dart`                                       | **baru**         | `AppUser {id, nama, email, role}`, `fromJson`, `isPemilik`                                                                                     |
| `lib/services/api_service.dart`                                  | **baru**         | **Satu-satunya** tempat memanggil server (lihat 5.3)                                                                                           |
| `lib/services/session_store.dart`                                | **baru**         | Token + user login di memori; `rutePertama` (pemilik → `profilPemilik`, selain itu → `home`)                                                   |
| `lib/services/favorit_store.dart`                                | **baru**         | `ValueNotifier<Set<String>> ids`, `muatDaftar`, `muat`, `sinkron`, `toggle` (pembaruan optimis + rollback)                                     |
| `lib/widgets/kost_image.dart`                                    | **baru**         | Gambar kost: path `assets/` → `Image.asset`; selain itu `Image.network`; kosong/gagal → placeholder                                            |
| `lib/widgets/favorit_button.dart`                                | **baru**         | Ikon hati; **otomatis tersembunyi** bila bukan pencari                                                                                         |
| `lib/widgets/kost_card.dart`                                     | diubah           | Memakai `KostImage` + `FavoritButton` (di `Stack`)                                                                                             |
| `lib/screens/pencari_kos/home_screen.dart`                       | diubah           | Stateful + `FutureBuilder` (loading/error/kosong, tombol "Coba lagi")                                                                          |
| `lib/screens/pencari_kos/detail_kost_screen.dart`                | diubah           | `KostImage` + `FavoritButton`; data dari `arguments`, tidak memanggil API sendiri                                                              |
| `lib/screens/pencari_kos/search_filter_screen.dart`              | diubah           | Stateful; kolom cari (debounce 500 ms), 4 panel filter (Harga, Fasilitas, Area, Urutkan), "Reset filter"                                       |
| `lib/screens/pencari_kos/favorit_screen.dart`                    | diubah           | Stateful; mendengarkan `FavoritStore.ids`                                                                                                      |
| `lib/screens/auth/login_screen.dart`                             | diubah           | Stateful; memanggil `ApiService.login`; `FavoritStore.sinkron()`; `pushNamedAndRemoveUntil` ke `SessionStore.rutePertama`                      |
| `lib/screens/auth/register_screen.dart`                          | diubah           | Stateful; pilihan peran bisa diketuk; langsung masuk setelah daftar                                                                            |
| `lib/screens/pemilik_kos/profil_pemilik_screen.dart`             | diubah           | Stateful; nama/email dari sesi; listing dari `fetchKostSaya`; Keluar menghapus sesi                                                            |
| `lib/screens/pemilik_kos/posting_edit_kost_screen.dart`          | diubah           | Stateful; controller untuk semua kolom; Simpan (`POST`/`PUT`), Hapus (dialog konfirmasi), kolom "Terisi" otomatis, kolom baru "Nomor WhatsApp" |
| `lib/screens/splash_screen.dart`, `onboarding_screen.dart`       | **tidak diubah** |                                                                                                                                                |
| `lib/app.dart`, `routes/app_routes.dart`, `theme/app_theme.dart` | **tidak diubah** |                                                                                                                                                |
| `lib/data/dummy_kost.dart`                                       | tidak dipakai    | Dibiarkan                                                                                                                                      |
| `pubspec.yaml`                                                   | diubah           | Ditambah paket `http` (via `flutter pub add http`). Dependensi lain: `google_fonts`, `url_launcher`                                            |

### 5.2 Alur data

```
Layar (StatefulWidget) ──► ApiService ──HTTP/JSON──► Express ──► SQLite
        ▲                      │
        │                      ├─ membaca token dari SessionStore (pakaiToken: true)
        └── mendengarkan ◄─ FavoritStore.ids (ValueNotifier) ◄─ ApiService (favorit)
```

### 5.3 Konvensi Flutter (wajib dijaga)

1. **Layar tidak boleh memanggil `http` langsung.** Semua lewat `ApiService`. Fungsi baru ditambahkan **di dalam kelas `ApiService`** (kelas ditutup `}` di baris paling akhir file).
2. **Pola layar yang mengambil data:** `StatefulWidget` + `late Future<...> _future` dibuat di `initState` + `FutureBuilder` dengan tiga keadaan (loading, error + tombol coba lagi, kosong) + fungsi `_muatUlang()` yang memanggil `setState`. Contoh acuan: `home_screen.dart`, `favorit_screen.dart`.
3. **Pola layar dengan aksi (form):** `TextEditingController` dibuat sebagai field dan **dibuang di `dispose()`**; pemeriksaan `if (!mounted) return;` setelah setiap `await` sebelum memakai `context` atau `setState`; satu fungsi pembungkus (`_jalankan`) untuk loading + penanganan error.
4. **Penanganan error:** `ApiException` (punya `code`, `message`, `statusCode`, getter `sesiBerakhir` = 401). Kesalahan jaringan/timeout (10 detik) → pesan umum "Tidak dapat terhubung ke server...". Status 401 pada layar yang butuh login → tawarkan "Masuk lagi" (hapus sesi, ke Login).
5. **Layar yang mengubah data menutup dengan `Navigator.pop(context, true)`**; layar pemanggil memuat ulang bila hasilnya `true` (contoh: Profil Pemilik ↔ Posting/Edit).
6. **Login, daftar, dan keluar memakai `pushNamedAndRemoveUntil(..., (route) => false)`** supaya tombol kembali tidak membawa ke layar sebelumnya.
7. **Semua tampilan gambar kost memakai `KostImage`**, bukan `Image.network`/`Image.asset` langsung.
8. **Angka dari form di-parse dulu** (`int.tryParse`) sebelum dikirim; server menolak angka berupa teks. Nomor WhatsApp dinormalkan di klien ke format `62...` (`0812...`, `812...`, dan `62812...` semuanya diterima).
9. **Mode Edit harus mengirim ulang semua field** (termasuk `imageUrl` lama), karena `PUT` mengganti seluruh data.
10. Gaya visual mengikuti dokumen 1 dan 2 (warna `AppColors`, `GoogleFonts.poppins` untuk judul, `GoogleFonts.inter` untuk isi, radius 12 sampai 16).

### 5.4 Rute dan argumen

| Rute                                             | Argumen           | Catatan                                                             |
| ------------------------------------------------ | ----------------- | ------------------------------------------------------------------- |
| `/` splash, `/onboarding`, `/login`, `/register` | -                 |                                                                     |
| `/home`, `/search-filter`, `/favorit`            | -                 |                                                                     |
| `/detail-kost`                                   | `Kost` (non-null) | Dikirim dari Home, Pencarian, Favorit                               |
| `/posting-edit-kost`                             | `Kost?`           | `null` = mode tambah. Menutup dengan hasil `true` bila data berubah |
| `/profil-pemilik`                                | -                 | Untuk pencari menghasilkan pesan akses ditolak (lihat tugas #3)     |

**Penting (Flutter web):** rute aplikasi ikut tertulis di URL (`#/login`, `#/home`, ...). Saat halaman di-refresh, aplikasi membuka rute yang ada di URL, bukan `initialRoute`. Sesi (di memori) hilang saat refresh.

### 5.5 Model `Kost` (Dart)

Field lama: `id, nama, alamat, harga, fasilitas, imageUrl, mapsUrl, whatsappNumber, status (enum KostStatus)`.
Field baru (bernilai bawaan supaya kode lama tetap terkompilasi): `patokan (String?)`, `kategoriPenyewa ('campur')`, `ukuranKamar ('-')`, `jumlahKamarTotal (0)`, `jumlahKamarKosong (0)`.
`imageUrl` bisa string kosong (dari `null` di server).

---

## 6. Keputusan desain dan alasannya

| Keputusan                                                | Alasan                                                                                                                                                                                                                       |
| -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Express + SQLite dulu, bukan Laravel atau langsung MySQL | Backend sudah jalan dan teruji; kelompok belum memakai PHP; migrasi hanya mengubah `db.js` dan kode query di balik kontrak (Flutter tidak berubah). Dosen kemudian mengonfirmasi MySQL                                       |
| Flutter hanya bicara ke kontrak API                      | Pergantian database/framework backend tidak boleh memengaruhi Flutter                                                                                                                                                        |
| `status` dihitung server dari jumlah kamar               | Form pemilik tidak punya field status; hanya total dan kosong yang disimpan, "terisi" diturunkan                                                                                                                             |
| `PUT` mengganti seluruh data                             | Form edit selalu mengirim semua field; lebih sederhana dan tidak ambigu                                                                                                                                                      |
| Favorit di database, endpoint idempoten                  | Permintaan tim; klik ganda atau pengulangan tidak merusak data                                                                                                                                                               |
| Favorit khusus pencari                                   | Pemilik tidak punya fitur favorit; mencegah data tak bermakna                                                                                                                                                                |
| Pembaruan optimis pada tombol hati + rollback            | Terasa cepat tanpa berbohong soal hasil akhir                                                                                                                                                                                |
| Sesi hanya di memori                                     | Penyimpanan permanen butuh `shared_preferences`; tidak wajib untuk tugas ini                                                                                                                                                 |
| Setelah daftar, pengguna langsung masuk                  | Server sudah mengembalikan token                                                                                                                                                                                             |
| Pemilik setelah login ke Profil Pemilik, pencari ke Home | Satu-satunya layar "rumah" pemilik adalah Profil Pemilik                                                                                                                                                                     |
| `FavoritStore` memakai `ValueNotifier`                   | Semua ikon hati tersinkron tanpa `setState` manual dan tanpa paket state management                                                                                                                                          |
| Filter fasilitas memakai logika AND                      | Pengguna mencari kost yang punya semua fasilitas yang diminta                                                                                                                                                                |
| "Area" = pencarian teks di `alamat`                      | Data tidak punya field area terpisah                                                                                                                                                                                         |
| Backend di folder dan repo terpisah dari Flutter         | Hindari repo Git bersarang; siklus kerja berbeda. **Catatan:** awalnya folder dibuat di dalam folder Flutter (`D:\Flutter Project\nge_kos\nge-kos-api`); pemindahan ke luar disarankan, status pemindahan belum dikonfirmasi |
| Branch `feat/api-integration` terpisah dari `main`       | `main` berisi tugas pertama (Stateless) yang dinilai                                                                                                                                                                         |
| Tidak mengunggah gambar ke database                      | Gambar disimpan sebagai file di server, database hanya menyimpan URL                                                                                                                                                         |

---

## 7. Batasan dan utang teknis yang diketahui

1. **Sesi hilang saat refresh/restart**; tidak ada penjaga rute (halaman bisa dibuka lewat URL tanpa login; API tetap menolak dengan 401).
2. **Pencari tidak punya tombol Keluar**, dan **ikon profil di Home** masih mengarah ke Profil Pemilik (shortcut demo lama), sehingga untuk pencari menghasilkan pesan akses ditolak (403).
3. **Profil Pemilik memakai foto yang sama untuk semua pemilik** (`assets/images/pemilik.jpg`).
4. **Upload foto belum ada.** Kolom foto di form Posting hanya tampilan. Kost baru tampil dengan gambar placeholder. Banner dan 4 foto belum bisa disimpan.
5. Tombol "Edit Profil" (Profil Pemilik), tombol "Buka Google Maps" di form, dan sapaan Home ("Halo, Pencari Kost") belum berfungsi/dinamis.
6. Pesan validasi dari server memakai nama field API (misalnya "jumlahKamarKosong harus...") dan ditampilkan apa adanya.
7. **Keamanan:** tidak ada pembatasan percobaan login, hanya HTTP (tanpa HTTPS), CORS terbuka untuk semua asal. Cukup untuk demo lokal, **tidak layak untuk internet**.
8. Filter `status` dilakukan di kode setelah query (tidak masalah untuk data kecil; perlu dirancang ulang bila ada pagination). Tidak ada pagination.
9. Akun seed memakai sandi sederhana (`password123`); hanya untuk lokal.
10. `fetchKostDetail` dan `dummy_kost.dart` belum/tidak dipakai (dibiarkan).

---

## 8. Pekerjaan lanjutan untuk anggota lain

**Urutan yang disarankan:** #1 dulu → #2 setelah #1 stabil → #3 dan #4 bebas dikerjakan kapan saja, paralel.
Pembagian penanggung jawab: _(diisi kelompok)_.

### Tugas #1 — Migrasi SQLite → MySQL (XAMPP + phpMyAdmin)

**Tujuan:** database berpindah ke MySQL; **kontrak API dan Flutter tidak berubah sama sekali**. Dosen sudah mengonfirmasi penggunaan MySQL.
**Pekerjaan:**

- Pasang `mysql2`; gunakan _connection pool_ (`mysql2/promise`). Buat database dan **user khusus** di phpMyAdmin (jangan `root` tanpa sandi). Simpan host, user, sandi, nama database di `.env` (buat juga `.env.example` tanpa nilai rahasia).
- Tulis ulang `src/db.js`: koneksi, skema (`AUTO_INCREMENT`, tipe kolom, **InnoDB** agar `ON DELETE CASCADE` bekerja), seed.
- Ubah **semua kode yang mengakses database menjadi `async/await`**: `routes/auth.js`, `kost.js`, `owner.js`, `favorit.js`, `utils/kost.js` (termasuk `formatDaftarKost`, `ambilFasilitas`, `ambilKostById`, yang semua pemanggilnya perlu `await`). Handler `async` harus memakai `try/catch` + `next(err)` (versi Express yang terpasang perlu dicek).
  **Jebakan yang pasti muncul:**
- **`rowid` tidak ada di MySQL.** Dua tempat memakainya untuk urutan: `ORDER BY rowid` di `ambilFasilitas` (urutan fasilitas) dan `ORDER BY f.rowid DESC` di `routes/favorit.js` (favorit terbaru di atas). Tambahkan kolom `id AUTO_INCREMENT` (atau kolom waktu) pada tabel `kost_fasilitas` dan `favorit`.
- `INSERT OR IGNORE` → `INSERT IGNORE`; `lastInsertRowid` → `insertId`; kode error email ganda `SQLITE_CONSTRAINT_UNIQUE` → `ER_DUP_ENTRY`; transaksi `db.transaction(...)` → transaksi pada koneksi dari pool (`beginTransaction`/`commit`/`rollback`).
- Hasil `LIKE` dan `LOWER()` pada MySQL bergantung pada _collation_; pastikan filter `q`, `area`, `fasilitas` tetap tidak peka huruf besar/kecil.
  **File yang perlu dilampirkan ke AI:** seluruh `src/` backend, `package.json`, `docs/API_CONTRACT.md`, dan dokumen ini.
  **Kriteria selesai:** seluruh suite regresi (bagian 9) menghasilkan respons **identik**; README menjelaskan cara menyiapkan XAMPP, database, dan `.env`; branch terpisah, dan versi SQLite yang lolos pengujian diberi tag Git sebagai titik kembali.

### Tugas #2 — Gambar banner kost dan 4 foto kamar (kerjakan SETELAH #1)

**Jawaban "apakah memungkinkan?":** ya, tetapi **bukan dengan menyimpan file gambar di dalam database**. File disimpan di folder server (`uploads/`), database hanya menyimpan URL-nya. BLOB di MySQL tidak disarankan (database membengkak dan lambat).
**Keadaan sekarang:** hanya ada kolom teks `image_url` (satu gambar). Tidak ada upload, tidak ada penyimpanan 4 foto. Banner = `imageUrl`.
**Rancangan yang disarankan** (kontrak perlu diperbarui dan disetujui kelompok):

- Server: paket `multer`; `POST /uploads` (khusus pemilik, `multipart/form-data`, field `file`) → `{ "url": "..." }`; folder `uploads/` disajikan lewat `express.static` **dipasang setelah `app.use(cors())`** (agar gambar bisa dimuat Flutter web; perlu diverifikasi pada versi Flutter yang dipakai); tabel baru `kost_foto (id, kost_id, url, urutan, jenis)` dengan `jenis` = tampak depan, kamar mandi, jendela, pintu masuk, dan `ON DELETE CASCADE`; objek Kost mendapat field `fotoUrls`.
- Alur dua langkah: unggah file dulu untuk mendapat URL, lalu kirim `imageUrl` dan `fotoUrls` (teks) pada `POST`/`PUT /kost`. Kontrak JSON tetap sederhana.
- **Keamanan upload (wajib):** batasi tipe (jpg, png, webp) dan ukuran file; periksa isi file, bukan hanya ekstensi; **ganti nama file dengan nama acak** (jangan pakai nama asli); hanya pemilik yang boleh unggah; hapus file dari disk saat kost dihapus atau fotonya diganti.
- Flutter: paket `image_picker` dan `http.MultipartRequest`. **Uji di Chrome**, bukan hanya emulator. Hubungkan kotak foto di form Posting/Edit (`_PhotoUploadGrid`, saat ini hanya tampilan). Layar Detail perlu galeri untuk 4 foto (saat ini hanya satu gambar).
- **`KostImage` harus diubah:** bila URL relatif (`/uploads/abc.jpg`), tambahkan `ApiService.baseUrl` di depannya.
- Mode Edit harus mempertahankan gambar lama bila pemilik tidak menggantinya.
  **File yang perlu dilampirkan:** backend: `src/index.js`, `db.js`, `routes/kost.js`, `utils/kost.js`, `package.json`, kontrak. Flutter: `posting_edit_kost_screen.dart`, `widgets/kost_image.dart`, `widgets/kost_card.dart`, `detail_kost_screen.dart`, `models/kost.dart`, `services/api_service.dart`, `pubspec.yaml`.
  **Kriteria selesai:** banner dan 4 foto terunggah, tersimpan, dan tampil di kartu serta Detail; file tipe atau ukuran tidak sah ditolak; menghapus kost menghapus filenya; Edit tidak menghilangkan gambar; suite regresi tetap lolos. **Ini pekerjaan terbesar yang tersisa; jangan meremehkan waktunya. Mulai dari banner (satu gambar) sebelum 4 foto.**

### Tugas #3 — Halaman Profil Pencari Kos

**Keputusan yang sudah disepakati:**

- Halaman profil khusus pencari **dibuat**, dengan isi **minimal**: kartu header (avatar **inisial nama**, nama, label "Pencari Kos", email), menu **"Favorit Saya"** (menampilkan jumlah favorit, membuka layar Favorit), dan tombol **"Keluar"**. Tidak ada daftar kost dan tidak ada tombol tambah.
- **Foto profil tidak diprioritaskan.** Pakai avatar inisial untuk kedua peran. Ganti juga foto tetap `pemilik.jpg` di Profil Pemilik dengan avatar inisial.
- Jangan mengumpulkan data pencari yang tidak dipakai (nomor HP, alamat).
- Tombol "Edit Profil" hanya diaktifkan bila endpoint ubah profil dibuat (belum ada); selain itu sembunyikan atau biarkan sebagai tampilan.
- Opsional nanti: nomor WhatsApp di profil pemilik (agar tidak mengetik ulang di tiap listing) dan foto profil pemilik (setelah infrastruktur upload dari tugas #2 ada).
  **Resep tombol Keluar (wajib ketiganya):**

```dart
SessionStore.hapus();
FavoritStore.ids.value = {};
Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
```

Tanpa baris kedua, favorit akun sebelumnya sempat terlihat di akun berikutnya.
**Perubahan lain yang diperlukan:** rute baru di `routes/app_routes.dart` dan `app.dart`; ikon profil di `home_screen.dart` diarahkan ke Profil Pencari (bukan lagi `profilPemilik`); data akun dari `SessionStore.user`.
**File yang perlu dilampirkan:** `profil_pemilik_screen.dart` (acuan gaya), `home_screen.dart`, `favorit_screen.dart`, `routes/app_routes.dart`, `app.dart`, `services/session_store.dart`, `services/favorit_store.dart`, `models/app_user.dart`.
**Kriteria selesai:** login pencari → Home; ikon profil di Home → Profil Pencari; Keluar mengembalikan ke Login dan akun lain tidak melihat favorit akun sebelumnya; pemilik tidak terpengaruh.

### Tugas #4 — Splash screen otomatis

**Perubahan:** Splash tampil 1 sampai 2 detik lalu otomatis ke Onboarding; **hapus tombol** yang sekarang harus diketuk.
**Cara:** ubah menjadi `StatefulWidget`; di `initState`: `Future.delayed(const Duration(seconds: 2), () { if (!mounted) return; Navigator.pushReplacementNamed(context, AppRoutes.onboarding); });`. Gunakan `pushReplacementNamed` agar tombol kembali tidak menuju Splash. Tombol di Splash dulu ada karena aturan Stateless pada tugas pertama; sekarang Stateful diperbolehkan.
**Catatan:** karena sesi hanya di memori, Splash selalu menuju Onboarding. Melewati Onboarding setelah pemakaian pertama dan masuk otomatis memerlukan `shared_preferences` (opsional). Di Flutter web, `initialRoute` hanya berlaku bila URL adalah `/`.
**File yang perlu dilampirkan:** `splash_screen.dart`, `onboarding_screen.dart`, `routes/app_routes.dart`.
**Kriteria selesai:** tanpa interaksi, Splash pindah ke Onboarding dalam 1 sampai 2 detik; tombol kembali dari Onboarding tidak membuka Splash.

---

## 9. Suite regresi (jalankan ulang setelah migrasi dan setiap perubahan besar)

Asumsi: database baru dengan data seed (bagian 2). Token: **A** = pemilik seed, **B** = pemilik kedua (daftar baru), **C** = pencari seed.

| Area    | Request / skenario                                                                                          | Harus menghasilkan                                                                                      |
| ------- | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Hidup   | `GET /health`                                                                                               | 200 `{"status":"ok"}`                                                                                   |
| Auth    | Register valid; ulangi email yang sama                                                                      | 201 dengan token dan user (tanpa sandi); lalu 409 `EMAIL_TAKEN`                                         |
| Auth    | Register `{}`, sandi `"123"`, role `"admin"`, email `"budi"`                                                | 400 `VALIDATION_ERROR` masing-masing                                                                    |
| Auth    | Login benar; sandi salah; email tak terdaftar                                                               | 200; 401 `INVALID_CREDENTIALS` (pesan sama untuk dua kasus gagal)                                       |
| Auth    | `GET /auth/me` tanpa header; `Bearer abc`; token sah                                                        | 401 `UNAUTHORIZED`; 401 `INVALID_TOKEN`; 200                                                            |
| Kost    | `GET /kost`                                                                                                 | `total: 3`, id `"1"`, `"2"`, `"3"`, status tersedia/hampir_penuh/penuh                                  |
| Kost    | `?q=melati`; `?area=gebang`; `?hargaMax=900000`                                                             | 1 (Melati); 1 (Griya Ayu); 2 (Melati, Griya Ayu)                                                        |
| Kost    | `?fasilitas=WiFi,AC`; `?fasilitas=wifi`; `?status=penuh`                                                    | 2 (Melati, Anggrek); 3; 1 (Anggrek)                                                                     |
| Kost    | `?sort=harga_asc`                                                                                           | Griya Ayu, Melati, Anggrek                                                                              |
| Kost    | `?hargaMin=abc`; `?sort=ngawur`; `?status=ngawur`                                                           | 400 untuk masing-masing                                                                                 |
| Kost    | `GET /kost/1`; `/kost/999`; `/kost/abc`                                                                     | 200 dengan `fasilitas` array; 404; 404                                                                  |
| Pemilik | `GET /owner/kost` token A / C / tanpa token                                                                 | `total: 3` / 403 / 401                                                                                  |
| Pemilik | `POST /kost` token A dengan body valid                                                                      | 201, `id: "4"`, `status` sesuai aturan, `patokan: null`, `imageUrl: null`                               |
| Pemilik | `POST /kost` dengan kosong > total; `harga` berupa teks; WA `081...`; fasilitas `["Kolam Renang"]`; token C | 400; 400; 400; 400; 403                                                                                 |
| Pemilik | `PUT /kost/4` token A (ubah kosong); token B; `PUT /kost/999`                                               | 200 dan status ikut berubah; 403; 404                                                                   |
| Pemilik | `DELETE /kost/1` token B; `DELETE /kost/4` token A; lalu `GET /kost/4`                                      | 403; 204; 404. Fasilitas kost 4 ikut terhapus                                                           |
| Favorit | `PUT /favorit/1` dua kali token C; `GET /favorit`                                                           | 204 keduanya; daftar berisi id `"1"`                                                                    |
| Favorit | Tambah id 3 lalu `GET /favorit`                                                                             | Urutan `"3"`, lalu `"1"` (terbaru di atas)                                                              |
| Favorit | `PUT /favorit/999`; `/favorit/abc`; token A (pemilik); tanpa token                                          | 404; 404; 403; 401                                                                                      |
| Favorit | `DELETE /favorit/1` dua kali                                                                                | 204 keduanya                                                                                            |
| Favorit | Pencari baru memanggil `GET /favorit`                                                                       | `total: 0`                                                                                              |
| Favorit | Kost yang difavoritkan dihapus pemiliknya                                                                   | Hilang dari `GET /favorit` pencari                                                                      |
| Flutter | Login pencari / pemilik                                                                                     | Ke Home / ke Profil Pemilik (menampilkan nama dan email akun)                                           |
| Flutter | Home, Pencarian (filter, urutan, reset), Detail                                                             | Data sama dengan hasil Thunder Client untuk query yang sama                                             |
| Flutter | Ketuk hati, hot restart, login ulang                                                                        | Hati yang tadi dipilih tetap terisi (bukti data di database)                                            |
| Flutter | Pemilik: tambah, edit (gambar lama tetap), hapus                                                            | Profil memuat ulang sesuai                                                                              |
| Flutter | Server dimatikan                                                                                            | Setiap layar menampilkan pesan koneksi dan tombol "Coba lagi"; ikon hati dikembalikan ke keadaan semula |

Cara paling pasti membandingkan: hasil di aplikasi harus sama dengan Thunder Client untuk URL yang sama (URL asli terlihat di tab Network DevTools Chrome).

---

## 10. Panduan: file apa yang dilampirkan ke AI (untuk menghemat waktu)

**Selalu lampirkan dokumen ini.** Lalu tambahkan sesuai jenis pekerjaan:

| Jenis pekerjaan                                        | Lampirkan                                                                                                                                       |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Menambah/mengubah **endpoint**                         | `docs/API_CONTRACT.md`, `src/index.js`, route terkait, `src/utils/kost.js`, `src/utils/http.js`, `src/middleware/auth.js`                       |
| Mengubah **skema database** / migrasi                  | `src/db.js`, semua file `src/routes/*` dan `src/utils/kost.js`, `package.json`                                                                  |
| Mengubah **validasi** kost                             | `src/utils/kost.js`, `routes/kost.js`, `docs/API_CONTRACT.md`, `posting_edit_kost_screen.dart`                                                  |
| Mengubah/menambah **layar Flutter** yang memanggil API | `services/api_service.dart`, layar terkait, `models/kost.dart` (bila perlu), `home_screen.dart` atau `favorit_screen.dart` sebagai contoh pola  |
| Masalah **login/sesi**                                 | `services/session_store.dart`, `services/api_service.dart`, `login_screen.dart`, `register_screen.dart`, `middleware/auth.js`, `routes/auth.js` |
| Masalah **favorit**                                    | `services/favorit_store.dart`, `widgets/favorit_button.dart`, `favorit_screen.dart`, `routes/favorit.js`, `services/api_service.dart`           |
| Masalah **gambar**                                     | `widgets/kost_image.dart`, `widgets/kost_card.dart`, `detail_kost_screen.dart`, `posting_edit_kost_screen.dart`, `models/kost.dart`             |
| Perubahan **tampilan/brand**                           | Dokumen 1 (brand), `theme/app_theme.dart`, layar terkait                                                                                        |
| **Error** (apa pun)                                    | Teks error lengkap + nama file + nomor baris + isi file yang bermasalah (**tempel sebagai teks**, bukan tangkapan layar)                        |

**Prinsip:** AI tidak boleh menebak isi file yang tidak dilampirkan. Bila kode aktual berbeda dengan dokumen ini, **kode aktual yang benar**, dan dokumen ini perlu diperbarui.

---

## 11. Konvensi kerja kelompok

1. **Satu branch per tugas** (`feat/migrasi-mysql`, `feat/upload-gambar`, `feat/profil-pencari`, `feat/splash-otomatis`); gabung lewat pull request, jangan push langsung ke `main`.
2. **Kontrak API adalah satu-satunya acuan** antara backend dan Flutter. Perubahan endpoint **wajib** memperbarui `docs/API_CONTRACT.md` dan dikabarkan ke grup.
3. Setiap perubahan backend dibuktikan dengan **menjalankan ulang tabel pengujian yang relevan** (bagian 9) dan hasilnya dilampirkan di pull request.
4. **Jangan commit `.env`, `*.db`, atau token.** Periksa dengan `git ls-files` sebelum push pertama.
5. Pesan commit berformat singkat dan jelas (contoh: `Favorit: tabel dan endpoint /favorit untuk pencari`).
6. Setiap AI di tangan anggota berbeda dapat menghasilkan gaya kode berbeda; **ikuti konvensi di bagian 3.4 dan 5.3**, dan tinjau hasil terhadap kontrak sebelum digabung.
7. Alat tes API: Thunder Client (gratis, per request) atau ekstensi REST Client dengan file `docs/api-tests.http`.

---

## 12. Pertanyaan terbuka

1. **Aturan Stateless/Stateful untuk tugas ini:** ada pernyataan "Stateful boleh bila memang diharuskan", tetapi jawaban dosen yang eksplisit untuk layar yang memanggil API belum dicatat.
2. **Deploy online atau cukup lokal:** dosen mengonfirmasi MySQL/XAMPP (menyiratkan lokal), tetapi kewajiban deploy online belum dicatat secara eksplisit.
3. **"Endpoint API" cukup berupa kontrak atau harus berjalan:** pada praktiknya sudah berjalan penuh.
4. **Kapan `feat/api-integration` digabung ke `main`:** `main` berisi tugas pertama yang dinilai dengan aturan Stateless. Putuskan setelah poin 1 jelas.
5. Lokasi akhir folder `nge-kos-api` (di dalam atau di luar folder proyek Flutter) dan apakah kedua repo sudah di-push ke GitHub: belum dikonfirmasi.
6. Tag Git `tugas-1-stateless` pada repo Flutter disarankan, belum dikonfirmasi sudah dibuat.

---

## 13. Prompt pembuka untuk sesi AI baru

Salin, lalu lampirkan **dokumen ini** dan file sesuai bagian 10:

```
Saya anggota kelompok proyek Flutter "Nge-Kos" (aplikasi pencari kost, mata kuliah
Pemrograman Aplikasi Mobile). Terlampir ringkasan sesi (dokumen integrasi REST API)
dan file kode yang relevan. Baca ringkasan itu dulu: di sana ada arsitektur, kontrak
API, konvensi kode, dan keputusan yang sudah disepakati.

Tugas saya: [tulis tugasnya, misalnya "Tugas #1 Migrasi MySQL" atau "tambah endpoint X"].

Aturan: jangan menebak isi file yang tidak terlampir; minta file itu. Kontrak API tidak
boleh berubah tanpa saya setuju dan dokumennya diperbarui. Ikuti konvensi bagian 3.4
(backend) dan 5.3 (Flutter). Berikan kode lengkap yang siap salin, langkah pengujian,
dan hasil yang diharapkan. Bila ada risiko atau kelemahan pada rencana saya, sebutkan
lebih dulu.
```
