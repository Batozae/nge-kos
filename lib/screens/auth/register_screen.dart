import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../widgets/primary_button.dart';
import '../../services/favorit_store.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'pencari'; // 'pencari' | 'pemilik'
  bool _sedangMemproses = false;
  String? _pesanError;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  Widget _roleOption(String label, IconData icon, String nilaiRole) {
    final selected = _role == nilaiRole;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = nilaiRole),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _daftar() async {
    if (_sedangMemproses) return;

    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _pesanError = 'Nama, email, dan kata sandi wajib diisi');
      return;
    }

    setState(() {
      _sedangMemproses = true;
      _pesanError = null;
    });

    try {
      await ApiService.register(
        nama: nama,
        email: email,
        password: password,
        role: _role,
      );
      FavoritStore.sinkron();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        SessionStore.rutePertama,
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _pesanError = e.message);
    } catch (e) {
      debugPrint('Register gagal: $e');
      if (!mounted) return;
      setState(
        () => _pesanError = 'Tidak dapat terhubung ke server. Pastikan server API sedang berjalan.',
      );
    } finally {
      if (mounted) setState(() => _sedangMemproses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Akun',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih peranmu di Nge-Kos',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _roleOption('Pencari Kos', Icons.search_rounded, 'pencari'),
                  const SizedBox(width: 12),
                  _roleOption(
                    'Pemilik Kos',
                    Icons.home_work_outlined,
                    'pemilik',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _namaController,
                decoration: _fieldDecoration(
                  'Nama Lengkap',
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onSubmitted: (_) => _daftar(),
                decoration: _fieldDecoration('Kata Sandi', Icons.lock_outline),
              ),
              if (_pesanError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _pesanError!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.statusFull,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                label: _sedangMemproses ? 'Memproses...' : 'Daftar',
                onPressed: _daftar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
