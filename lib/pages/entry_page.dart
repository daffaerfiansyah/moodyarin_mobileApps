import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moodyarin/models/mood_entry.dart';
import 'package:moodyarin/widgets/slide_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});
  

  @override
  State<EntryPage> createState() => _EntryPageState();
}
class _EntryPageState extends State<EntryPage> {
  DateTime _currentDate = DateTime.now();
  List<MoodEntry> _moodEntries = [];
  int _selectedWeek = 0; // 0 = semua
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    fetchMoodEntries();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasUsed = prefs.getBool('hasUsedApp') ?? false;

    setState(() {
      _isFirstTime = !hasUsed;
    });
  }

  Future<void> fetchMoodEntries() async {
    final start = DateTime(_currentDate.year, _currentDate.month, 1);
    final end = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    final response = await Supabase.instance.client
        .from('mood_entries')
        .select()
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String());

    final data = response as List;
    final moods = data.map((e) => MoodEntry.fromJson(e)).toList();

    setState(() {
      _moodEntries = moods;
    });

    if (_moodEntries.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasUsedApp', true);

      setState(() {
        _isFirstTime = false;
      });
    }
  }

  String get formattedMonthYear {
    return DateFormat('MMMM yyyy', 'id_ID').format(_currentDate);
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
    fetchMoodEntries();
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
    fetchMoodEntries();
  }

  List<MoodEntry> get filteredMoodEntries {
    if (_selectedWeek == 0) return _moodEntries;

    return _moodEntries.where((entry) {
      final day = entry.date.day;
      final week = ((day - 1) ~/ 7) + 1;
      return week == _selectedWeek;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Panah kiri
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            // Teks tengah
            Expanded(
              child: Center(
                child: Text(
                  formattedMonthYear,
                  style: GoogleFonts.jua(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Panah kanan
            Padding(
              padding: const EdgeInsets.only(right: 48),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // FILTER MINGGU
            // TAMPILKAN DROPDOWN JIKA ADA MOOD
            (_isFirstTime && _moodEntries.isEmpty)
                ? GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/mood');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          'assets/IMG-10.png',
                          height: 30,
                          width: 30,
                          color: Colors.white,
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
                )
                : (_moodEntries.isNotEmpty
                    ? DropdownButtonHideUnderline(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 1, 24, 1),
                        child: DropdownButtonFormField<int>(
                          value: _selectedWeek,
                          isExpanded: true,
                          alignment: Alignment.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(37, 11, 5, 11),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                          dropdownColor: Colors.blue.shade50,
                          icon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.blueAccent,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          items: List.generate(5, (index) {
                            final label =
                                index == 0 ? 'Semua' : 'Minggu $index';
                            return DropdownMenuItem<int>(
                              value: index,
                              alignment: Alignment.center,
                              child: Center(
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                _selectedWeek = value;
                              });
                            }
                          },
                        ),
                      ),
                    )
                    : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Belum ada data mood bulan ini',
                          style: GoogleFonts.poppins(
                            color: Colors.blueGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )),

            const SizedBox(height: 16),

            // JIKA TIDAK ADA MOOD
            Expanded(
              child:
                  _moodEntries.isEmpty
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 180,
                            child: Image.asset('assets/IMG-08.png'),
                          ),
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
                            style: GoogleFonts.poppins(
                              color: Colors.blueGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                      // JIKA ADA MOOD ENTRY
                      : ListView.builder(
                        itemCount: filteredMoodEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredMoodEntries[index];
                          return SwipeableCard(
                            entry: entry,
                            onEdit: () {
                              // TODO: Navigasi ke halaman edit
                            },
                            onDelete: () {
                              // TODO: Konfirmasi hapus
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
