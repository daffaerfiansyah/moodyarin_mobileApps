import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodyarin/models/mood_entry.dart'; 
import 'package:moodyarin/services/mood_service.dart'; 
import 'package:intl/intl.dart';

class EditMoodModal extends StatefulWidget {
  final MoodEntry? entry; 
  final DateTime dateForEntry; 

  const EditMoodModal({
    super.key,
    this.entry,
    required this.dateForEntry,
  });

  @override
  State<EditMoodModal> createState() => _EditMoodModalState();
}

class _EditMoodModalState extends State<EditMoodModal> {
  late final TextEditingController _noteController;
  int? _selectedMoodIndex;
  bool get _isEditMode => widget.entry != null;

  final List<Map<String, dynamic>> moodList = [
    {'label': 'Sangat Sedih', 'asset': 'assets/Emoji-1.png'},
    {'label': 'Sedih', 'asset': 'assets/Emoji-2.png'},
    {'label': 'Biasa aja', 'asset': 'assets/Emoji-3.png'},
    {'label': 'Baik', 'asset': 'assets/Emoji-4.png'},
    {'label': 'Sangat Baik', 'asset': 'assets/Emoji-5.png'},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _noteController = TextEditingController(text: widget.entry!.note);
      _selectedMoodIndex = moodList.indexWhere(
        (mood) => mood['label'] == widget.entry!.mood,
      );
    } else {
      _noteController = TextEditingController();
      _selectedMoodIndex = null;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_selectedMoodIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih mood Anda."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final moodLabel = moodList[_selectedMoodIndex!]['label'];
    final noteText = _noteController.text;

    try {
      MoodEntry resultEntry;
      if (_isEditMode) {
        final updatedEntry = MoodEntry(
          id: widget.entry!.id,
          date: widget.entry!.date,
          mood: moodLabel,
          note: noteText,
        );
        await MoodService.updateMood(updatedEntry);
        resultEntry = updatedEntry;
      } else {
        final newEntry = MoodEntry(
          id: '',
          date: widget.dateForEntry,
          mood: moodLabel,
          note: noteText,
        );
        await MoodService.saveMood(newEntry);
        resultEntry =
            newEntry;
      }

      if (mounted) {
        Navigator.of(
          context,
        ).pop(resultEntry);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? 'Edit Catatan Mood'
                  : 'Tambah Catatan Mood', 
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat(
                'EEEE, d MMMM yyyy',
                'id_ID',
              ).format(widget.dateForEntry),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Bagaimana perasaanmu?",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(moodList.length, (index) {
                final isSelected = _selectedMoodIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMoodIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected
                              ? Colors.blue.shade100
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.blue.shade300
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Image.asset(
                      moodList[index]['asset'],
                      width: 40,
                      height: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(
              "Tambahkan catatan (opsional):",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Apa yang sedang kamu pikirkan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditMode
                      ? 'Simpan Perubahan'
                      : 'Simpan Mood',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
