import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moodyarin/models/mood_entry.dart';
import 'package:moodyarin/services/mood_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:moodyarin/widgets/edit_modal.dart';

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isLoading = true;
  Map<DateTime, List<MoodEntry>> _moodEvents = {};

  static const Map<String, String> _emojiAssets = {
    'Sangat Baik': 'assets/Emoji-5.png',
    'Baik': 'assets/Emoji-4.png',
    'Biasa aja': 'assets/Emoji-3.png',
    'Sedih': 'assets/Emoji-2.png',
    'Sangat Sedih': 'assets/Emoji-1.png',
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchMoodDataForMonth(_focusedDay);
  }

  Future<void> _fetchMoodDataForMonth(DateTime date) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    try {
      final response = await Supabase.instance.client
          .from('mood_entries')
          .select()
          .gte('date', firstDayOfMonth.toIso8601String())
          .lte('date', lastDayOfMonth.toIso8601String())
          .order('date', ascending: true);

      final List<dynamic> data = response as List;
      final Map<DateTime, List<MoodEntry>> events = {};
      for (var item in data) {
        final entry = MoodEntry.fromJson(item);
        final eventDate = DateTime.utc(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        if (events[eventDate] == null) {
          events[eventDate] = [];
        }
        events[eventDate]!.add(entry);
      }

      if (mounted) {
        setState(() {
          _moodEvents = events;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data kalender: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<MoodEntry> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _moodEvents[normalizedDay] ?? [];
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
        isError ? Icons.info_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _deleteEntryFromCalendar(
    String entryId,
    DateTime entryDate,
  ) async {
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
        await MoodService.deleteMood(entryId);
        final eventDate = DateTime.utc(
          entryDate.year,
          entryDate.month,
          entryDate.day,
        );
        if (_moodEvents.containsKey(eventDate)) {
          setState(() {
            _moodEvents[eventDate]!.removeWhere((e) => e.id == entryId);
            if (_moodEvents[eventDate]!.isEmpty) {
              _moodEvents.remove(eventDate);
            }
          });
        }
        showTopSnackbar('Catatan berhasil dihapus!', isError: false);
      } catch (e) {
        showTopSnackbar('Gagal menghapus: $e');
      }
    }
  }


  Future<void> _openMoodFormModal({
    MoodEntry? entry,
    required DateTime forDate,
  }) async {
    final MoodEntry? resultEntry = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return EditMoodModal(entry: entry, dateForEntry: forDate);
      },
    );

    if (resultEntry != null) {
      _fetchMoodDataForMonth(_focusedDay);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showTopSnackbar(
            entry == null
                ? 'Mood berhasil ditambahkan!'
                : 'Catatan berhasil diperbarui!',
            isError: false,
          );
        }
      });
    }
  }

  void _showMoodDetails(
    BuildContext context,
    List<MoodEntry> entries,
    DateTime day,
  ) {
    bool isEmptyEntry = entries.isEmpty;
    MoodEntry? entryToShow = isEmptyEntry ? null : entries.first;
    String mainDialogTitle = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(day);

    Widget dialogContent;
    List<Widget> dialogActions = [];

    if (isEmptyEntry) {
      final DateTime now = DateTime.now();
      final DateTime todayNormalized = DateTime.utc(
        now.year,
        now.month,
        now.day,
      );
      final DateTime selectedDayNormalized = DateTime.utc(
        day.year,
        day.month,
        day.day,
      );

      bool isFutureDate = selectedDayNormalized.isAfter(todayNormalized);

      if (isFutureDate) {
        dialogContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/IMG-08.png',
              height: 80,
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada catatan untuk hari yang akan datang.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 20),
          ],
        );
      } else {
        dialogContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/IMG-08.png', height: 80),
            const SizedBox(height: 16),
            Text(
              "Belum ada catatan mood untuk tanggal ini.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                "Tambah Catatan Mood",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _openMoodFormModal(
                  forDate: day,
                );
              },
            ),
          ],
        );
      }
    } else {
      entryToShow = entries.first; 
      dialogContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              _emojiAssets[entryToShow.mood] ?? _emojiAssets['Biasa aja']!,
              width: 60,
              height: 60,
            ),
          ),
          Center(
            child: Text(
              entryToShow.mood,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(entryToShow.date),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Catatan:",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entryToShow.note.isNotEmpty
                ? entryToShow.note
                : "Tidak ada catatan",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
      dialogActions = [
        TextButton(
          child: Text(
            "Edit",
            style: GoogleFonts.poppins(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _openMoodFormModal(
              entry: entryToShow,
              forDate:
                  entryToShow!.date, 
            );
          },
        ),
        const SizedBox(width: 8),
        TextButton(
          child: Text(
            "Hapus",
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _deleteEntryFromCalendar(entryToShow!.id, entryToShow.date);
          },
        ),
      ];
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  top:
                      45, 
                  right: 20,
                  bottom: 20,
                ),
                margin: const EdgeInsets.only(
                  top: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    dialogContent, 
                    if (dialogActions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: dialogActions,
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                right: 0.0,
                top: 0.0, 
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Icon(Icons.close, color: Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
    _fetchMoodDataForMonth(_focusedDay);
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
    _fetchMoodDataForMonth(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    String formattedMonthYear = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(_focusedDay);

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
                onPressed: _navigateToPreviousMonth,
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
                onPressed: _navigateToNextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.only(
                bottom: 16,
                left: 8,
                right: 8,
                top: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.shade400,
                    const Color.fromARGB(255, 75, 71, 188),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar<MoodEntry>(
                locale: 'id_ID',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                daysOfWeekHeight: 40,
                rowHeight: 80,
                headerVisible: false,
                availableGestures: AvailableGestures.none,

                calendarStyle: CalendarStyle(
                  defaultDecoration: const BoxDecoration(),
                  weekendDecoration: const BoxDecoration(),
                  selectedDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  outsideTextStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),                
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (
                    BuildContext context,
                    DateTime day,
                    List<MoodEntry> events,
                  ) {
                    return const SizedBox.shrink();
                  },
                  prioritizedBuilder: (context, day, focusedDay) {
                    final events = _getEventsForDay(day);
                    bool isSelected = isSameDay(_selectedDay, day);
                    bool isToday = isSameDay(day, DateTime.now());
                    bool isOutside = day.month != focusedDay.month;

                    Widget dayContentWidget;
                    Widget? markerContentWidget;
                    double outsideContentOpacity = 0.5;

                    if (isOutside) {
                      dayContentWidget = Text(
                        '${day.day}',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(
                            outsideContentOpacity * 0.8,
                          ),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      );
                      if (events.isNotEmpty) {
                        final moodLabel = events.first.mood;
                        final assetPath = _emojiAssets[moodLabel];
                        if (assetPath != null) {
                          markerContentWidget = Opacity(
                            opacity: outsideContentOpacity,
                            child: Image.asset(
                              assetPath,
                              width: 48,
                              height: 48,
                            ),
                          );
                        } else {
                          markerContentWidget = Opacity(
                            opacity: outsideContentOpacity,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange.withOpacity(
                                  0.7 * outsideContentOpacity,
                                ),
                              ),
                            ),
                          );
                        }
                      } else {
                        markerContentWidget = Opacity(
                          opacity: outsideContentOpacity,
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                0.4 * outsideContentOpacity,
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      Color dayNumberColor;
                      if (isSelected) {
                        dayNumberColor = Colors.deepPurple.shade700;
                      } else if (isToday) {
                        dayNumberColor = Colors.purple.shade600;
                      } else {
                        dayNumberColor = Colors.white.withOpacity(0.9);
                      }
                      dayContentWidget = Text(
                        '${day.day}',
                        style: GoogleFonts.poppins(
                          color: dayNumberColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      );
                      if (events.isNotEmpty) {
                        final moodLabel = events.first.mood;
                        final assetPath = _emojiAssets[moodLabel];
                        if (assetPath != null) {
                          markerContentWidget = Image.asset(
                            assetPath,
                            width: 48,
                            height: 48,
                          );
                        } else {
                          markerContentWidget = Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.withOpacity(0.7),
                            ),
                          );
                        }
                      } else {
                        markerContentWidget = Container(
                          width: 35,
                          height: 35,
                          margin: EdgeInsets.fromLTRB(4, 6, 4, 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        );
                      }
                    }
                    BoxDecoration cellContainerDecoration = BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color:
                          isSelected
                              ? Colors.white.withOpacity(0.3)
                              : isToday && !isSelected
                              ? Colors.white.withOpacity(0.15)
                              : Colors.transparent, 
                    );
                    return Container(
                      margin: const EdgeInsets.all(1.0),
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      decoration: cellContainerDecoration,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (markerContentWidget != null) ...[
                            markerContentWidget,
                          ] else ...[
                            const SizedBox(
                              height: 48,
                            ),
                          ],
                          const SizedBox(height: 2),
                          dayContentWidget,
                        ],
                      ),
                    );
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    );
                  });
                  _showMoodDetails(
                    context,
                    _getEventsForDay(selectedDay),
                    selectedDay,
                  );
                },
                onPageChanged: (focusedDay) {
                  if (!isSameDay(_focusedDay, focusedDay)) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                    _fetchMoodDataForMonth(focusedDay);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
