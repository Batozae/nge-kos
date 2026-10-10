import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../models/kost.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../widgets/kost_card.dart';
import '../../widgets/primary_button.dart';

/// Halaman Profil Pemilik Kos: info akun + daftar listing milik pemilik (dari API).
/// Ketuk listing -> Posting/Edit (mode edit). Tombol tambah -> form kosong.
class ProfilPemilikScreen extends StatefulWidget {
  const ProfilPemilikScreen({super.key});

  @override
  State<ProfilPemilikScreen> createState() => _ProfilPemilikScreenState();
}

class _ProfilPemilikScreenState extends State<ProfilPemilikScreen> {
  static const String _fotoPemilikPath = 'assets/images/pemilik.jpg';

  late Future<List<Kost>> _futureKost;

  @override
  void initState() {
    super.initState();
    _futureKost = ApiService.fetchKostSaya();
  }

  void _muatUlang() {
    setState(() {
      _futureKost = ApiService.fetchKostSaya();
    });
  }

  // Membuka form; kalau form menutup dengan hasil true (data berubah), muat ulang daftar
  Future<void> _bukaForm([Kost? kost]) async {
    final berubah = await Navigator.pushNamed(
      context,
      AppRoutes.postingEditKost,
      arguments: kost,
    );
    if (berubah == true && mounted) _muatUlang();
  }

  void _keluar() {
    SessionStore.hapus();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Widget _tampilanError(Object? error) {
    debugPrint('Gagal memuat kost saya: $error');
    final sesiBerakhir = error is ApiException && error.sesiBerakhir;
    final String pesan;
    if (sesiBerakhir) {
      pesan = 'Sesi login berakhir. Silakan masuk lagi.';
    } else if (error is ApiException) {
      pesan = error.message;
    } else {
      pesan = 'Tidak dapat terhubung ke server. Pastikan server API sedang berjalan.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: sesiBerakhir ? _keluar : _muatUlang,
              child: Text(sesiBerakhir ? 'Masuk lagi' : 'Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bagianKostSaya() {
    return FutureBuilder<List<Kost>>(
      future: _futureKost,
      builder: (context, snapshot) {
        final selesai = snapshot.connectionState == ConnectionState.done;
        final daftar = snapshot.data ?? <Kost>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kost Saya',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (selesai && !snapshot.hasError)
                  Text(
                    '${daftar.length} listing',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!selesai)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.hasError)
              _tampilanError(snapshot.error)
            else if (daftar.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Belum ada kost yang kamu posting.',
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...daftar.map(
                (kost) => KostCard(kost: kost, onTap: () => _bukaForm(kost)),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    backgroundImage: AssetImage(_fotoPemilikPath),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.nama ?? 'Pemilik Kos',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Pemilik Kos',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    text: user?.email ?? '-',
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(label: 'Edit Profil', onPressed: () {}),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _bagianKostSaya(),

            const SizedBox(height: 8),
            PrimaryButton(
              label: '+ Tambah Kost Baru',
              onPressed: () => _bukaForm(),
            ),

            const SizedBox(height: 24),

            // Logout
            Center(
              child: TextButton.icon(
                onPressed: _keluar,
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.statusFull,
                ),
                label: Text(
                  'Keluar',
                  style: GoogleFonts.inter(
                    color: AppColors.statusFull,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
