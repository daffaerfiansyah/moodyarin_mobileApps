import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodyarin/models/mood_entry.dart';
import 'package:intl/intl.dart';

class SwipeableCard extends StatefulWidget {
  final MoodEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SwipeableCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  double _offset = 0.0;
  final double maxSlide = 120.0;

  // Map label to asset path
  static const Map<String, String> _emojiAssets = {
    'Sangat Sedih': 'assets/Emoji-1.png',
    'Sedih': 'assets/Emoji-2.png',
    'Biasa aja': 'assets/Emoji-3.png',
    'Baik': 'assets/Emoji-4.png',
    'Sangat Baik': 'assets/Emoji-5.png',
  };

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset -= details.delta.dx;
      _offset = _offset.clamp(0.0, maxSlide);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_offset > maxSlide / 2) {
      setState(() => _offset = maxSlide);
    } else {
      setState(() => _offset = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine asset based on entry.mood
    final assetPath = _emojiAssets[widget.entry.mood] ?? 'assets/Emoji-3.png';

    return Stack(
      children: [
        // 🔙 Buttons behind
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.lightBlue),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
        ),

        // 📦 Card that can be swiped
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: Offset(-_offset, 0),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.indigo.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      assetPath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE, d MMMM yyyy',
                            'id_ID',
                          ).format(widget.entry.date),
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.entry.mood,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.entry.note,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
