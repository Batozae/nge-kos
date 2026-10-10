import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../models/kost.dart';
import '../../services/api_service.dart';
import '../../widgets/kost_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Kost>> _futureKost;

  @override
  void initState() {
    super.initState();
    _futureKost = ApiService.fetchKostList();
  }

  void _muatUlang() {
    setState(() {
      _futureKost = ApiService.fetchKostList();
    });
  }

  Widget _tampilanError(Object? error) {
    debugPrint('Gagal memuat kost: $error');
    final pesan = error is ApiException
        ? error.message
        : 'Tidak dapat terhubung ke server. Pastikan server API sedang berjalan.';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            pesan,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: _muatUlang, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  Widget _daftarKost() {
    return FutureBuilder<List<Kost>>(
      future: _futureKost,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _tampilanError(snapshot.error);
        }

        final daftar = snapshot.data ?? [];
        if (daftar.isEmpty) {
          return Center(
            child: Text(
              'Belum ada kost yang tersedia',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: daftar.length,
          itemBuilder: (context, i) {
            final kost = daftar[i];
            return KostCard(
              kost: kost,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.detailKost,
                arguments: kost,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, Pencari Kost 👋',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Cari kost impianmu',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.profilPemilik),
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.searchFilter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        'Cari nama kost, area...',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.tune_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Rekomendasi Kost',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(child: _daftarKost()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, AppRoutes.favorit);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }
}
