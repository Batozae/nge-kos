import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Widget tombol standar aplikasi agar tampilan CTA konsisten di berbagai halaman
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    // Definisi tampilan dasar ElevatedButton dengan warna Terracotta
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );

    // Jika fullWidth true, bungkus tombol dengan SizedBox berukuran double.infinity
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
