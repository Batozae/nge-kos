import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../widgets/primary_button.dart';

// Halaman pengenalan fitur utama aplikasi kepada pengguna baru
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.house_rounded, size: 100, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'Cari Kost Jadi Gampang',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Temukan kost sesuai budget dan lokasi, langsung hubungi pemiliknya lewat WhatsApp tanpa ribet.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // Tombol untuk mengarahkan pengguna ke Halaman Login
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Mulai',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
