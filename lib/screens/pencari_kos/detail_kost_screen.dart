import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/kost_image.dart';
import '../../theme/app_theme.dart';
import '../../models/kost.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/favorit_button.dart';

/// Halaman Detail Kost yang menampilkan info lengkap 1 objek Kost yang dikirim
/// lewat `Navigator.pushNamed(..., arguments: kost)` dari Home / Hasil

class DetailKostScreen extends StatelessWidget {
  final Kost kost;

  const DetailKostScreen({super.key, required this.kost});

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

  Future<void> _bukaWhatsapp() async {
    final uri = Uri.parse('https://wa.me/${kost.whatsappNumber}');
    // gagal — belum diimplementasikan di fase desain ini.
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _bukaMaps() async {
    final uri = Uri.parse(kost.mapsUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Gambar + tombol back ===
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    child: KostImage(imageUrl: kost.imageUrl, height: 240),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FavoritButton(kostId: kost.id),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === Nama + Badge Status ===
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            kost.nama,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusLabel,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // === Alamat + tombol lihat lokasi ===
                    GestureDetector(
                      onTap: _bukaMaps,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              kost.alamat,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            'Lihat di Maps',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // === Harga ===
                    Text(
                      'Rp${kost.harga}/bulan',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // === Fasilitas ===
                    Text(
                      'Fasilitas',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: kost.fasilitas.map((f) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            f,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 100), // ruang untuk bottom bar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom bar: CTA WhatsApp
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Chat via WhatsApp',
            onPressed: _bukaWhatsapp,
          ),
        ),
      ),
    );
  }
}
