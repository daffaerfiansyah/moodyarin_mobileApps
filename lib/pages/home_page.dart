import 'package:flutter/material.dart';
import 'package:moodyarin/widgets/bottom_navigation.dart';
import 'package:moodyarin/pages/entry_page.dart';
import 'package:moodyarin/pages/mood_page.dart';
// Tambahkan halaman lain jika sudah tersedia
// import 'package:moodyarin/pages/statistik_page.dart';
// import 'package:moodyarin/pages/kalender_page.dart';
// import 'package:moodyarin/pages/profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // final List<Widget> _pages = const [
  //   EntryPage(),
  //   // StatistikPage(),
  //   // MoodPage(),
  //   // KalenderPage(),
  //   // ProfilPage(),
  // ];

  final List<Widget> _pages = const [
    EntryPage(),
    Center(child: Text("Statistik")),
    MoodPage(),
    Center(child: Text("Kalender")),
    Center(child: Text("Profil")),
  ];


  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // ✅ Tidak naik saat keyboard
      body: _pages[_selectedIndex],

      // ✅ FAB tetap pakai bawaan Scaffold
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onNavTapped(2),
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.emoji_emotions, color: Colors.white, size: 28),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ✅ BottomNavigationBar menyatu seperti biasa
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
