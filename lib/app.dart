import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/pencari_kos/home_screen.dart';
import 'screens/pencari_kos/search_filter_screen.dart';
import 'screens/pemilik_kos/posting_edit_kost_screen.dart';
import 'screens/pemilik_kos/profil_pemilik_screen.dart';
import 'screens/pencari_kos/favorit_screen.dart';
import 'screens/pencari_kos/detail_kost_screen.dart';
import 'models/kost.dart';

// Root widget aplikasi yang mengonfigurasi tema global dan sistem navigasi/routing
class NgeKosApp extends StatelessWidget {
  const NgeKosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nge-Kos',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // Menerapkan konfigurasi tema kustom dari app_theme.dart
      initialRoute: AppRoutes
          .splash, // Menentukan halaman awal saat app dibuka (Splash Screen)
      routes: {
        // Peta rute navigasi aplikasi
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.searchFilter: (context) => const SearchFilterScreen(),
        AppRoutes.favorit: (context) => const FavoritScreen(),
        AppRoutes.profilPemilik: (context) => const ProfilPemilikScreen(),

        // Rute posting/edit kost dengan passing argument
        AppRoutes.postingEditKost: (context) {
          final kost = ModalRoute.of(context)!.settings.arguments as Kost?;
          return PostingEditKostScreen(kost: kost);
        },

        // Rute detail kost dengan passing argument (non-nullable: data kost wajib ada)
        AppRoutes.detailKost: (context) {
          final kost = ModalRoute.of(context)!.settings.arguments as Kost;
          return DetailKostScreen(kost: kost);
        },
      },
    );
  }
}
