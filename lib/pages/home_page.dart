import 'package:flutter/material.dart';
import 'package:moodyarin/widgets/bottom_navigation.dart';
import 'package:moodyarin/pages/entry_page.dart';
import 'package:moodyarin/pages/mood_page.dart';
// Tambahkan halaman lain jika sudah tersedia
// import 'package:moodyarin/pages/statistik_page.dart';
// import 'package:moodyarin/pages/kalender_page.dart';
// import 'package:moodyarin/pages/profil_page.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // pakai argumen saat initState
  }

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
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onNavTapped(2),
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.emoji_emotions, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

