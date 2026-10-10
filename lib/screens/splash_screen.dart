import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

// Halaman pertama yang muncul saat aplikasi dibuka
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Branding Nama Aplikasi
            Text(
              'Nge-Kos',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cari kost, tanpa ribet',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                // Menimpa rute agar pengguna tidak bisa kembali ke Splash Screen via tombol back
                Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
              },
              child: const Text('Mulai'),
            ),
          ],
        ),
      ),
    );
  }
}
