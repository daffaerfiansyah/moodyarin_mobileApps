import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moodyarin/routes/routes.dart';
import 'package:moodyarin/constant.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('is_first_open') ?? true;

  final session = Supabase.instance.client.auth.currentSession;
  final isLoggedIn = session != null;

  String initialRoute;
  if (isFirstTime) {
    await prefs.setBool('is_first_open', false);
    initialRoute = AppRoutes.splash;
  } else {
    initialRoute = isLoggedIn ? AppRoutes.homepage : AppRoutes.login;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);


  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodyarIn',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        // Locale('en', 'US'), // Tambahkan jika perlu bahasa Inggris
      ],
      locale: const Locale('id', 'ID'),
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
