import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../widgets/primary_button.dart';
import '../../services/favorit_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _sedangMemproses = false;
  String? _pesanError;

  @override
  void dispose() {
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

  Future<void> _masuk() async {
    if (_sedangMemproses) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _pesanError = 'Email dan kata sandi wajib diisi');
      return;
    }

    setState(() {
      _sedangMemproses = true;
      _pesanError = null;
    });

    try {
      await ApiService.login(email, password);
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
      debugPrint('Login gagal: $e');
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Masuk',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lanjutkan pencarian kost kamu',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onSubmitted: (_) => _masuk(),
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
                label: _sedangMemproses ? 'Memproses...' : 'Masuk',
                onPressed: _masuk,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Belum punya akun? '),
                        TextSpan(
                          text: 'Daftar',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
