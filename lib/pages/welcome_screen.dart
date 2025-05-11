import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodyarin/utils/backhandle_wrapper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _zoomOutController;
  late Animation<double> _zoomOutAnimation;

  @override
  void initState() {
    super.initState();

    // Controller untuk Zoom Out
    _zoomOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _zoomOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _zoomOutController, curve: Curves.easeInOut),
    );

    _zoomOutAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, '/intro');
      }
    });

    // Controller untuk animasi logo (muncul)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _zoomOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackHandlerWrapper(
      onBack: () {
        Navigator.pushReplacementNamed(context, '/');
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: ScaleTransition(
                scale: _zoomOutAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Image.asset('assets/Text_Logo.png'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'My Special Day',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromARGB(255, 23, 151, 255),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hiasi harian Anda,\ntemani cerita Anda',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        Image.asset(
                          'assets/IMG-01.png',
                          height: 320,
                          fit: BoxFit.contain,
                        ),
                        Transform.translate(
                          offset: const Offset(0, -60),
                          child: Image.asset(
                            'assets/IMG-02.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),

          // Tombol Lanjut di luar Scaffold (tetap di dalam Stack)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  _zoomOutController.forward();
                },
                child: const Text(
                  'Lanjut',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
