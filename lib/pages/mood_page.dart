import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

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

  void showMoodSavedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "MoodSaved",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SizedBox(); // kosong karena kita pakai transitionBuilder
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
                          'Catatan Mood harian kamu sudah \ntersimpan.Selamat beraktivitas dan jangan lupa untuk bahagia :)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jua(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.blue),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                          width: 64, // Lebar tetap
                          height: 100, // Tinggi tetap untuk keseluruhan item
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
                                height:
                                    40, // Tinggi tetap untuk teks 2 baris (kira-kira 2 x fontSize)
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
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Catatan
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
                    style: const TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      hintText: 'Tambah Catatan...',
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
            const SizedBox(height: 160),

            Text(
              "Simpan jika Catatan Mood Harian kamu sudah kamu cantumkan.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(
                  double.infinity,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                showMoodSavedDialog(context);
              },
              child: const Text("Simpan", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
