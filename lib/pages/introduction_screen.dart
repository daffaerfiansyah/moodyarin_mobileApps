import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodyarin/utils/backhandle_wrapper.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackHandlerWrapper(
      onBack: () {
        Navigator.pushReplacementNamed(context, '/welcome');
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Gambar atas memenuhi lebar layar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/IMG-03.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.43,
              ),
            ),

            // Konten bawah
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Jaga Pikiran Anda,\nSatu Emoji Sekaligus',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ungkapkan Mood dan pengalaman anda\n'
                      'melalui bahasa emoji dan catatan harian.\n\n'
                      'Kamu akan bisa '
                      'merasakan fitur dengan\n nyaman dan '
                      'tanpa tekanan.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Dengan menekan Lanjut, anda menyetujui\n'
                      'Persyaratan Layanan dan Kebijakan Privasi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
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
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          'Lanjut',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
