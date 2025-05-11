import 'package:flutter/material.dart';
import 'package:moodyarin/pages/splash_screen.dart';
import 'package:moodyarin/pages/welcome_screen.dart';
import 'package:moodyarin/pages/introduction_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const introduction = '/intro';

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
      // case introduction:
      //   return PageRouteBuilder(
      //     pageBuilder: (_, __, ___) => const IntroductionScreen(),
      //     transitionDuration: Duration.zero,
      //     reverseTransitionDuration: Duration.zero,
      //   );
      case introduction:
        return MaterialPageRoute(builder: (_) => const IntroductionScreen());
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
