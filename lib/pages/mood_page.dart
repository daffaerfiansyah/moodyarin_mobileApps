import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:moodyarin/models/mood_entry.dart';
import 'package:moodyarin/services/mood_service.dart';
import 'package:another_flushbar/flushbar.dart';

class MoodPage extends StatefulWidget {
  final MoodEntry? entryToEdit;
  const MoodPage({super.key, this.entryToEdit});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  int? selectedMood;
  final TextEditingController _noteController = TextEditingController();
  

  final List<Map<String, dynamic>> moodList = [
    {"emoji": "assets/Emoji-1.png", "label": "Sangat Sedih"},
    {"emoji": "assets/Emoji-2.png", "label": "Sedih"},
    {"emoji": "assets/Emoji-3.png", "label": "Biasa aja"},
    {"emoji": "assets/Emoji-4.png", "label": "Baik"},
    {"emoji": "assets/Emoji-5.png", "label": "Sangat Baik"},
  ];

  String getFormattedDate() {
    final now = DateTime.now();
    const monthNames = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return "${now.day} ${monthNames[now.month]} ${now.year}";
  }

  DateTime getTodayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day); // hanya tanggal, tanpa jam
  }

  void showMoodSavedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "MoodSaved",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = Curves.easeOut.transform(animation.value) - 1.0;

        return Transform.translate(
          offset: Offset(0, curvedValue * -300),
          child: Opacity(
            opacity: animation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/IMG-09.png', height: 100),
                        const SizedBox(height: 16),
                        Text(
                          'Catatan Mood harian kamu sudah \ntersimpan. Selamat beraktivitas dan jangan lupa untuk bahagia :)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jua(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed:
                              () => Navigator.pushReplacementNamed(
                                context,
                                '/home',
                                arguments: 0,
                              ),
                          child: const Text(
                            'Tap untuk melanjutkan',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showTopSnackbar(String message, {bool isError = true}) {
    Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home', arguments: 0);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          getFormattedDate(),
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 120,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bagaimana hari ini?",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(moodList.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMood = index;
                                });
                              },
                              child: SizedBox(
                                width: 64,
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            selectedMood == index
                                                ? Colors.white
                                                : Colors.transparent,
                                        border:
                                            selectedMood == index
                                                ? null
                                                : Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          moodList[index]['emoji'],
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 40,
                                      child: Text(
                                        moodList[index]['label'],
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.jua(
                                          color:
                                              selectedMood == index
                                                  ? Colors.white
                                                  : Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ingin catatan hari ini?",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _noteController,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Tambah Catatan...',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Simpan jika Catatan Mood Harian kamu\n sudah kamu cantumkan.",
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        if (selectedMood != null) {
                          final entry = MoodEntry(
                            id: '',
                            date: getTodayDate(),
                            mood: moodList[selectedMood!]['label'],
                            note: _noteController.text,
                          );

                          try {
                            await MoodService.saveMood(entry);
                            showMoodSavedDialog(context);
                          } catch (e) {
                            showTopSnackbar('Gagal menyimpan mood: $e');
                          }
                        } else {
                          showTopSnackbar(
                            'Silahkan pilih mood terlebih dahulu.',
                          );
                        }
                      },
                      child: const Text(
                        "Simpan",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
