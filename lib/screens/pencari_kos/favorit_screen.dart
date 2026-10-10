import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/kost.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/favorit_store.dart';
import '../../services/session_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/kost_card.dart';

class FavoritScreen extends StatefulWidget {
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  late Future<List<Kost>> _futureFavorit;

  @override
  void initState() {
    super.initState();
    _futureFavorit = FavoritStore.muatDaftar();
  }

  void _muatUlang() {
    setState(() {
      _futureFavorit = FavoritStore.muatDaftar();
    });
  }

  void _keLogin() {
    SessionStore.hapus();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Favorit',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<List<Kost>>(
        future: _futureFavorit,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error);
          }

          final semua = snapshot.data ?? <Kost>[];

          // Mendengarkan perubahan: kalau hati dilepas, kartunya hilang dari sini
          return ValueListenableBuilder<Set<String>>(
            valueListenable: FavoritStore.ids,
            builder: (context, ids, _) {
              final favoritKostList = semua
                  .where((k) => ids.contains(k.id))
                  .toList();

              if (favoritKostList.isEmpty) return _buildEmptyState();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${favoritKostList.length} kost tersimpan',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final kost in favoritKostList)
                    KostCard(
                      kost: kost,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.detailKost,
                          arguments: kost,
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildError(Object? error) {
    debugPrint('Gagal memuat favorit: $error');
    final sesiBerakhir = error is ApiException && error.sesiBerakhir;
    final String pesan;
    if (sesiBerakhir) {
      pesan = 'Sesi login berakhir. Silakan masuk lagi.';
    } else if (error is ApiException) {
      pesan = error.message;
    } else {
      pesan = 'Tidak dapat terhubung ke server. Pastikan server API sedang berjalan.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              onPressed: sesiBerakhir ? _keLogin : _muatUlang,
              child: Text(sesiBerakhir ? 'Masuk lagi' : 'Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada kost favorit',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ketuk ikon hati pada kost yang kamu suka, '
              'nanti muncul di sini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      onTap: (index) {
        if (index == 0) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          label: 'Favorit',
        ),
      ],
    );
  }
}
