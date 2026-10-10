import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/favorit_store.dart';
import '../services/session_store.dart';
import '../theme/app_theme.dart';

// Ikon hati untuk menandai favorit. Hanya tampil untuk akun pencari.
class FavoritButton extends StatelessWidget {
  final String kostId;

  const FavoritButton({super.key, required this.kostId});

  void _tampilkanPesan(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _ubah(BuildContext context) async {
    try {
      await FavoritStore.toggle(kostId);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      _tampilkanPesan(
        context,
        e.sesiBerakhir ? 'Sesi login berakhir. Silakan masuk lagi.' : e.message,
      );
    } catch (_) {
      if (!context.mounted) return;
      _tampilkanPesan(context, 'Tidak dapat terhubung ke server.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.user;
    if (user == null || user.isPemilik) return const SizedBox.shrink();

    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoritStore.ids,
      builder: (context, ids, _) {
        final aktif = ids.contains(kostId);
        return GestureDetector(
          onTap: () => _ubah(context),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: Icon(
              aktif ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 20,
              color: aktif ? AppColors.statusFull : AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
