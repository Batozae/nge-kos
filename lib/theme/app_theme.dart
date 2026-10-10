import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Definisi konstanta warna sesuai Brand Identity "Nge-Kos"
class AppColors {
  static const primary = Color(0xFF1B4965);
  static const secondary = Color(0xFFEE964B);
  static const background = Color(0xFFFAF9F6);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const statusAvailable = Color(0xFF4C956C);
  static const statusAlmostFull = Color(0xFFEE964B);
  static const statusFull = Color(0xFFC1121F);
}

// Konfigurasi ThemeData global untuk menjaga konsistensi visual di seluruh halaman
ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    secondary: AppColors.secondary,
  ),
  // Pengaturan Tipografi Global menggunakan Google Fonts (Poppins & Inter)
  textTheme: TextTheme(
    headlineMedium: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary),
    bodySmall: GoogleFonts.inter(color: AppColors.textSecondary),
  ),
  // Styling Card global dengan sudut membulat (border radius 14)
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
);
