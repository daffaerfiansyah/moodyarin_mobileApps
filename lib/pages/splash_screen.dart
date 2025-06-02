import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodyarin/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double dragValue = 0.0;
  bool isDraggingComplete = false;
  String _shouldGoTo = AppRoutes.welcome; // default

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final isFirstOpen = prefs.getBool('is_first_open') ?? true;
    final session = Supabase.instance.client.auth.currentSession;

    // Simpan ke state supaya bisa digunakan setelah geser
    setState(() {
      _shouldGoTo = session != null ? AppRoutes.login : isFirstOpen ? AppRoutes.welcome : AppRoutes.login;
    });
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              AnimatedOpacity(
                opacity: isDraggingComplete ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 700),
                child: AnimatedSlide(
                  offset:
                      isDraggingComplete ? const Offset(0, -1.5) : Offset.zero,
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      Image.asset('assets/Logo.png', width: 150),
                      const SizedBox(height: 16),
                      Image.asset('assets/Text_Logo.png', width: 300),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Stack(
                children: [
                  Container(
                    width: screenWidth,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  // Teks di tengah yang menghilang saat digeser
                  Positioned.fill(
                    child: Center(
                      child: Opacity(
                        opacity:
                            1.0 -
                            (dragValue / (screenWidth * 0.6)).clamp(0.0, 1.0),
                        child: Text(
                          'Geser untuk Memulai',
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Slider (draggable button) yang tetap center secara vertikal
                  Positioned(
                    top: 2,
                    bottom: 2,
                    left: dragValue,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          dragValue += details.delta.dx;
                          dragValue = dragValue.clamp(0, screenWidth - 60);
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        if (dragValue > screenWidth * 0.6) {
                          setState(() => isDraggingComplete = true);
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) {
                              // Selalu cek mounted
                              // Tambahkan pengecekan untuk melihat apakah kita sudah di halaman reset password
                              // Ini cara sederhana, mungkin perlu disesuaikan jika rute Anda kompleks
                              final currentRouteName =
                                  ModalRoute.of(context)?.settings.name;
                              if (currentRouteName != AppRoutes.resetPassword) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  _shouldGoTo,
                                );
                              } else {
                                print(
                                  "SplashScreen: Navigasi normal dibatalkan karena sudah di halaman reset password.",
                                );
                              }
                            }
                          });
                        } else {
                          setState(() {
                            dragValue = 0;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 56,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.blue,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
