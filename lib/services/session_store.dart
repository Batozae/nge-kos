import '../models/app_user.dart';
import '../routes/app_routes.dart';

// Penyimpan sesi login di memori (hilang saat aplikasi dimuat ulang)
class SessionStore {
  static String? token;
  static AppUser? user;

  static bool get sudahLogin => token != null && user != null;

  static void simpan(String tokenBaru, AppUser userBaru) {
    token = tokenBaru;
    user = userBaru;
  }

  static void hapus() {
    token = null;
    user = null;
  }

  // Layar tujuan setelah login atau daftar berhasil
  static String get rutePertama {
    return (user?.isPemilik ?? false)
        ? AppRoutes.profilPemilik
        : AppRoutes.home;
  }
}
