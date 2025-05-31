import 'package:flutter/material.dart';
import 'package:moodyarin/pages/mood_page.dart';
import 'package:moodyarin/pages/splash_screen.dart';
import 'package:moodyarin/pages/welcome_screen.dart';
import 'package:moodyarin/pages/introduction_screen.dart';
import 'package:moodyarin/widgets/login_screen.dart';
import 'package:moodyarin/widgets/register_screen.dart';
import 'package:moodyarin/pages/home_page.dart';
import 'package:moodyarin/pages/entry_page.dart';
import 'package:moodyarin/pages/edit_profil_page.dart';

class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const introduction = '/intro';
  static const login = '/login';
  static const register = '/regist';
  static const homepage = '/home';
  static const entry = '/entry';
  static const mood = '/mood';
  static const editProfil = '/edit-profil';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      case entry:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const EntryPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      // case introduction:
      //   return PageRouteBuilder(
      //     pageBuilder: (_, __, ___) => const IntroductionScreen(),
      //     transitionDuration: Duration.zero,
      //     reverseTransitionDuration: Duration.zero,
      //   );
      case introduction:
        return MaterialPageRoute(builder: (_) => const IntroductionScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case mood:
        return MaterialPageRoute(builder: (_) => const MoodPage());
      case homepage:
        // cek apakah ada argument bertipe int, jika tidak default 0
        final int initialIndex =
            (settings.arguments is int) ? settings.arguments as int : 0;
        return MaterialPageRoute(
          builder: (_) => HomePage(initialIndex: initialIndex),
        );
      // case entry:
      //   return MaterialPageRoute(builder: (_) => const EntryPage());
      case editProfil:
        return MaterialPageRoute(builder: (_) => const EditProfilPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Halaman tidak ditemukan')),
              ),
        );
    }
  }
}
