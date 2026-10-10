import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/kost_image.dart';
import '../models/kost.dart';
import '../theme/app_theme.dart';

// Widget reusable untuk menampilkan ringkasan informasi kost dalam bentuk kartu
class KostCard extends StatelessWidget {
  final Kost kost; // Menerima data model Kost
  final VoidCallback? onTap;

  const KostCard({super.key, required this.kost, this.onTap});

  Color get _statusColor => switch (kost.status) {
    KostStatus.tersedia => AppColors.statusAvailable,
    KostStatus.hampirPenuh => AppColors.statusAlmostFull,
    KostStatus.penuh => AppColors.statusFull,
  };

  String get _statusLabel => switch (kost.status) {
    KostStatus.tersedia => 'Tersedia',
    KostStatus.hampirPenuh => 'Hampir Penuh',
    KostStatus.penuh => 'Penuh',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.06,
              ), // Penggunaan .withValues untuk menghindari deprecation
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: KostImage(imageUrl: kost.imageUrl, height: 140),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Kost dan Badge Status Ketersediaan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          kost.nama,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: _statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Informasi Alamat Kost
                  Text(
                    kost.alamat,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Informasi Harga per Bulan
                  Text(
                    'Rp${kost.harga}/bulan',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
