import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  DateTime _currentDate = DateTime.now();

  String get formattedMonthYear {
    return DateFormat('MMMM yyyy', 'id_ID').format(_currentDate);
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        formattedMonthYear,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tombol biru dengan gambar dan teks
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/mood',
                  ); // Ganti sesuai route mood kamu
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/IMG-10.png', // Ganti dengan ikon gambar kamu
                        height: 30,
                        width: 30,
                        color: Colors.white, // Sesuaikan warna jika perlu
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Yakali hari-harinya sama',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('🎉', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 120),
              SizedBox(height: 180, child: Image.asset('assets/IMG-08.png')),
              const SizedBox(height: 20),
              Text(
                'Ayo, ekspresikan mood kamu\nuntuk pertama kalinya',
                textAlign: TextAlign.center,
                style: GoogleFonts.jua(
                  color: Colors.blueAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Klik tombol emoji pada navigasi\ndibawah ini!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.blueGrey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
