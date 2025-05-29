import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moodyarin/models/mood_entry.dart';
import 'package:moodyarin/services/mood_service.dart';
import 'package:moodyarin/widgets/slide_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';

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
  bool _isLoading = true;

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
    if (!mounted) return;
    setState(() {
      _isLoading = true; // <-- Set true di awal
    });

    final start = DateTime(_currentDate.year, _currentDate.month, 1);
    final end = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    try {
      // Tambahkan try-catch untuk penanganan error yang lebih baik
      final response = await Supabase.instance.client
          .from('mood_entries')
          .select()
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String())
          .order(
            'date',
            ascending: false,
          ); // <-- Sesuai permintaan sebelumnya, data terbaru di atas

      final data = response as List;
      final moods = data.map((e) => MoodEntry.fromJson(e)).toList();

      if (!mounted) return;
      setState(() {
        _moodEntries = moods;
        // _isLoading akan di set false setelah pengecekan _isFirstTime
      });

      if (_moodEntries.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasUsedApp', true);
        if (mounted) {
          // Selalu cek mounted sebelum setState di async gap
          setState(() {
            _isFirstTime = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        showTopSnackbar('Gagal memuat data: $e');
      }
    } finally {
      // Pastikan isLoading selalu di-set false
      if (mounted) {
        setState(() {
          _isLoading = false; // <-- Set false di akhir (di dalam finally)
        });
      }
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

  void showTopSnackbar(String message, {bool isError = true}) {
    if (!mounted) return;

    Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
      icon: Icon(
        isError
            ? Icons.info_outline
            : Icons.check_circle_outline,
        color: Colors.white,
      ),
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _deleteEntry(String id) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus catatan mood ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await MoodService.deleteMood(id);

        setState(() {
          _moodEntries.removeWhere((entry) => entry.id == id);
        });

        if (mounted) {
          showTopSnackbar('Catatan Berhasil Dihapus!', isError: false);
        }
      } catch (e) {
        if (mounted) {
          showTopSnackbar('Gagal Menghapus: $e');
        }
      }
    }
  }

  Future<void> _showEditModal(MoodEntry entry) async {
    final MoodEntry? updatedEntry = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return EditMoodModal(entry: entry);
      },
    );

    if (updatedEntry != null) {
      final index = _moodEntries.indexWhere((e) => e.id == updatedEntry.id);
      if (index != -1) {
        setState(() {
          _moodEntries[index] = updatedEntry;
        });
      }
      showTopSnackbar('Catatan berhasil diperbarui!', isError: false);
    }
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
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
          children: [
            (_isFirstTime && _moodEntries.isEmpty && !_isLoading)
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
                : (_moodEntries.isNotEmpty || !_isLoading)
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
                    ),
            const SizedBox(height: 16),
            Expanded(
                    child: RefreshIndicator(
                      onRefresh: fetchMoodEntries, // Panggil fungsi fetch saat di-refresh
                      child: _moodEntries.isEmpty && !_isLoading // Tambah cek !_isLoading
                          ? LayoutBuilder( // Gunakan LayoutBuilder agar RefreshIndicator berfungsi saat kosong
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                    child: Center(
                                      child: _isFirstTime // Jika ini pertama kali dan daftar kosong
                                          ? Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 180, child: Image.asset('assets/IMG-08.png')),
                                                const SizedBox(height: 20),
                                                Text('Ayo, ekspresikan mood kamu\nuntuk pertama kalinya', textAlign: TextAlign.center, style: GoogleFonts.jua(color: Colors.blueAccent, fontSize: 24, fontWeight: FontWeight.w600)),
                                                const SizedBox(height: 8),
                                                Text('Klik tombol emoji pada navigasi\ndibawah ini!', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.blueGrey, fontSize: 14)),
                                              ],
                                            )
                                          : Column(
                                            children: [
                                              SizedBox(
                                                height: 180,
                                                  child: Image.asset(
                                                      'assets/IMG-08.png',
                                                    ),
                                                  ),
                                                  Text(
                                                    'Belum ada catatan mood untuk bulan ini.\nGeser ke bawah untuk memuat ulang.',
                                                    textAlign:
                                                        TextAlign.center,
                                                     style:
                                                      GoogleFonts.poppins(
                                                         color:Colors.blueGrey,
                                                         fontSize: 14,
                                                        ),
                                                  ),
                                            ],
                                          )
                                    ),
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              itemCount: filteredMoodEntries.length,
                              itemBuilder: (context, index) {
                                final entry = filteredMoodEntries[index];
                                return SwipeableCard(
                                  entry: entry,
                                  onEdit: () => _showEditModal(entry),
                                  onDelete: () => _deleteEntry(entry.id),
                                );
                              },
                            ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class EditMoodModal extends StatefulWidget {
  final MoodEntry entry;

  const EditMoodModal({super.key, required this.entry});

  @override
  State<EditMoodModal> createState() => _EditMoodModalState();
}

class _EditMoodModalState extends State<EditMoodModal> {
  late final TextEditingController _noteController;
  int? _selectedMoodIndex;


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
    // Isi form dengan data yang sudah ada
    _noteController = TextEditingController(text: widget.entry.note);
    _selectedMoodIndex = moodList.indexWhere(
      (mood) => mood['label'] == widget.entry.mood,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (_selectedMoodIndex == null) return; 

    final updatedEntry = MoodEntry(
      id: widget.entry.id, 
      date: widget.entry.date, 
      mood: moodList[_selectedMoodIndex!]['label'],
      note: _noteController.text,
    );

    try {
      await MoodService.updateMood(updatedEntry);
      if (mounted) {
        Navigator.of(context).pop(updatedEntry);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui: $e'),
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
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Catatan Mood',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(moodList.length, (index) {
              final isSelected = _selectedMoodIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedMoodIndex = index),
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.5,
                  child: Image.asset(
                    moodList[index]['asset'],
                    width: 48,
                    height: 48,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
