import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Menampilkan gambar kost dari asset lokal atau URL, dengan cadangan jika kosong/gagal
class KostImage extends StatelessWidget {
  final String imageUrl;
  final double height;

  const KostImage({super.key, required this.imageUrl, required this.height});

  Widget _placeholder() {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Icon(
        Icons.home_work_outlined,
        size: 40,
        color: AppColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) return _placeholder();

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }
}
