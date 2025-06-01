import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moodyarin/routes/routes.dart';
import 'package:moodyarin/constant.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await initializeDateFormatting('id_ID', null);
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('is_first_open') ?? true;
  final session = Supabase.instance.client.auth.currentSession;
  final isLoggedIn = session != null;

  String initialRoute;
  if (isFirstTime) {
    initialRoute = AppRoutes.splash;
  } else {
    initialRoute = isLoggedIn ? AppRoutes.homepage : AppRoutes.login;
  }
  print("MAIN.DART: Initial route determined: $initialRoute");

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final AuthChangeEvent event = data.event;
        print("[MyApp] Auth Event Diterima: $event");

        if (event == AuthChangeEvent.passwordRecovery) {
          print(
            "[MyApp] Event PasswordRecovery terdeteksi! Akan menjadwalkan navigasi.",
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              print(
                "[MyApp] Batal navigasi: _MyAppState tidak mounted saat addPostFrameCallback.",
              );
              return;
            }
            if (navigatorKey.currentState != null) {
              print(
                "[MyApp] navigatorKey.currentState SIAP. Melakukan navigasi ke ${AppRoutes.resetPassword}",
              );
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                AppRoutes.resetPassword,
                (route) => false,
              );
              print(
                "[MyApp] Navigasi ke ResetPasswordPage TELAH DIPANGGIL via GlobalKey.",
              );
            } else {
              print(
                "[MyApp] GAGAL NAVIGASI: navigatorKey.currentState adalah null. MaterialApp mungkin belum sepenuhnya siap atau GlobalKey tidak terpasang dengan benar.",
              );
            }
          });
        }
      },
      onError: (error) {
        print("[MyApp] Error pada Auth Listener: $error");
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MoodyAhrin',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID')],
      locale: const Locale('id', 'ID'),
      initialRoute: widget.initialRoute,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
