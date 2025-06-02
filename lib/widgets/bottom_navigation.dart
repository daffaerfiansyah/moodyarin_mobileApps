import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 239, 249, 254),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.format_list_bulleted_outlined, 
              label: 'Entri', 
              index: 0
            ),
            _buildNavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Statistik',
              index: 1,
            ),
            const SizedBox(width: 40),
            _buildNavItem(
              icon: Icons.calendar_month_rounded,
              label: 'Kalender',
              index: 3,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.blue.shade700 : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.blue.shade700 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
