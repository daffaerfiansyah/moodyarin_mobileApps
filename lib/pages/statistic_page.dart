import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moodyarin/models/mood_entry.dart';
import 'package:moodyarin/services/mood_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  DateTime _currentDate = DateTime.now();
  bool _isLoading = true;
  List<MoodEntry> _allMoodsForMonth = [];
  String? _selectedMoodLabel;

  String get formattedMonthYear {
    return DateFormat('MMMM yyyy', 'id_ID').format(_currentDate);
  }

  static const Map<String, double> _moodValueMap = {
    'Sangat Baik': 5.0,
    'Baik': 4.0,
    'Biasa aja': 3.0,
    'Sedih': 2.0,
    'Sangat Sedih': 1.0,
  };

  static const Map<String, String> _emojiAssets = {
    'Sangat Baik': 'assets/Emoji-5.png',
    'Baik': 'assets/Emoji-4.png',
    'Biasa aja': 'assets/Emoji-3.png',
    'Sedih': 'assets/Emoji-2.png',
    'Sangat Sedih': 'assets/Emoji-1.png',
  };

  // Color map for moods
  static const Map<String, Color> _moodColorMap = {
    'Sangat Baik': Color(0xFFFBBF24),
    'Baik': Color(0xFF34D399),
    'Biasa aja': Color(0xFF60A5FA),
    'Sedih': Color.fromARGB(255, 255, 154, 95),
    'Sangat Sedih': Color(0xFFEF4444),
  };

  @override
  void initState() {
    super.initState();
    _fetchAndProcessData();
  }

  Future<void> _fetchAndProcessData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _selectedMoodLabel = null; // Reset interaksi saat data baru dimuat
    });

    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    try {
      final response = await Supabase.instance.client
          .from('mood_entries')
          .select()
          .gte('date', firstDay.toIso8601String())
          .lte('date', lastDay.toIso8601String())
          .order('date', ascending: true);

      final List<dynamic> data = response as List;
      final moods = data.map((e) => MoodEntry.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _allMoodsForMonth = moods;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Tampilkan pesan error jika gagal mengambil data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, int> _calculateMoodDistribution(List<MoodEntry> entries) {
    final Map<String, int> distribution = {};
    for (var entry in entries) {
      distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
    }
    return distribution;
  }

  List<FlSpot> _processDataForLineChart(List<MoodEntry> entries) {
    if (entries.isEmpty) return [];

    final List<int> targetDays = [1, 7, 14, 21, 28, 30, 31];
    final List<FlSpot> spots = [];

    for (int i = 0; i < targetDays.length; i++) {
      int day = targetDays[i];
      MoodEntry? closestEntry;
      for (var entry in entries.where((e) => e.date.day <= day)) {
        closestEntry = entry;
      }

      if (closestEntry != null) {
        final yValue = _moodValueMap[closestEntry.mood] ?? 3.0;
        spots.add(FlSpot(i.toDouble(), yValue));
      }
    }
    return spots;
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _selectedMoodLabel = null; // Reset pilihan saat ganti bulan
    });
    _fetchAndProcessData();
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _selectedMoodLabel = null; // Reset pilihan saat ganti bulan
    });
    _fetchAndProcessData();
  }
  

  @override
  Widget build(BuildContext context) {
    final lineChartSpots = _processDataForLineChart(_allMoodsForMonth);
    final moodDistribution = _calculateMoodDistribution(_allMoodsForMonth);
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
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _allMoodsForMonth.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader(
                      'Grafik Mood Sebulan',
                      'Lihat Grafik kamu dalam satu bulan',
                      const Color(0xFF4F46E5),
                    ),
                    const SizedBox(height: 12),
                    _buildLineChartCard(lineChartSpots),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      'Perhitungan Mood',
                      'Sentuh Mood untuk melihat detail jumlah!',
                      const Color(0xFF4F46E5),
                    ),
                    const SizedBox(height: 12),
                    _buildRadialGaugeCard(moodDistribution),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartCard(List<FlSpot> spots) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            spreadRadius: 4,
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        height: 220,
        child:
            spots.isEmpty
                ? Center(
                  child: Text(
                    "Data bulan ini tidak cukup untuk menampilkan grafik.",
                    style: GoogleFonts.poppins(),
                  ),
                )
                : LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine:
                          (value) => const FlLine(
                            color: Color(0xffe7e8ec),
                            strokeWidth: 1,
                          ),
                      getDrawingVerticalLine:
                          (value) => const FlLine(
                            color: Color(0xffe7e8ec),
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: _leftTitles()),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(sideTitles: _bottomTitles()),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: const Color(0xffe7e8ec),
                        width: 1,
                      ),
                    ),
                    minX: 0,
                    maxX: 6,
                    minY: 1,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [Colors.cyan, Colors.red.shade400],
                        ),
                        barWidth: 5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withOpacity(0.3),
                              Colors.red.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  // Ganti seluruh fungsi _buildRadialGaugeCard Anda dengan versi ini.

  Widget _buildRadialGaugeCard(Map<String, int> distribution) {
    final orderedMoodKeys = [
      'Sangat Sedih',
      'Sedih',
      'Biasa aja',
      'Baik',
      'Sangat Baik',
    ];
    final totalValue = distribution.values.fold(0, (sum, item) => sum + item);

    final chartMoodKeys =
        orderedMoodKeys.where((key) => (distribution[key] ?? 0) > 0).toList();

    final List<PieChartSectionData> sections = List.generate(
      chartMoodKeys.length,
      (i) {
        final moodName = chartMoodKeys[i];
        final isTouched = moodName == _selectedMoodLabel;
        final radius = isTouched ? 35.0 : 25.0;
        final value = distribution[moodName]?.toDouble() ?? 0;

        return PieChartSectionData(
          color: _moodColorMap[moodName],
          value: value,
          title: '',
          radius: radius,
        );
      },
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            spreadRadius: 4,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    // --- PERUBAHAN UTAMA ADA DI SINI ---
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          // Hanya bereaksi jika gestur sentuhan sudah selesai (tap diangkat)
                          if (event is FlTapUpEvent || event is FlPanEndEvent) {
                            if (pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              // Jika menekan area kosong, batalkan pilihan
                              _selectedMoodLabel = null;
                            } else {
                              // Jika menekan segmen, terapkan logika toggle
                              final touchedIndex =
                                  pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                              final touchedMoodName =
                                  chartMoodKeys[touchedIndex];

                              // Jika menekan yang sudah terpilih, batalkan. Jika baru, pilih.
                              if (_selectedMoodLabel == touchedMoodName) {
                                _selectedMoodLabel = null;
                              } else {
                                _selectedMoodLabel = touchedMoodName;
                              }
                            }
                          }
                        });
                      },
                    ),
                    sections: sections,
                    startDegreeOffset: 180,
                    centerSpaceRadius: 70,
                    sectionsSpace: 4,
                  ),
                ),
                // Teks di tengah (kode ini tidak perlu diubah, akan bekerja otomatis)
                Builder(
                  builder: (context) {
                    final value =
                        _selectedMoodLabel != null
                            ? distribution[_selectedMoodLabel]
                            : null;

                    if (_selectedMoodLabel == null ||
                        value == null ||
                        totalValue == 0) {
                      return Text(
                        'Sentuh Grafik',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      );
                    }

                    final percentage = (value / totalValue * 100)
                        .toStringAsFixed(0);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$percentage%',
                          style: GoogleFonts.jua(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _moodColorMap[_selectedMoodLabel!],
                          ),
                        ),
                        Text(
                          _selectedMoodLabel!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Legenda Emoji (kode ini tidak perlu diubah)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                orderedMoodKeys.map((moodLabel) {
                  final assetPath = _emojiAssets[moodLabel]!;
                  final count = distribution[moodLabel] ?? 0;
                  final isSelected = _selectedMoodLabel == moodLabel;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMoodLabel = isSelected ? null : moodLabel;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Opacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          child: Text(
                            '${count} Hari',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.indigo.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: isSelected ? 55 : 50,
                          height: isSelected ? 55 : 50,
                          child: Image.asset(assetPath),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  SideTitles _leftTitles() => SideTitles(
    showTitles: true,
    reservedSize: 36,
    getTitlesWidget: (value, meta) {
      String? assetPath;
      switch (value.toInt()) {
        case 1:
          assetPath = _emojiAssets['Sangat Sedih'];
          break;
        case 2:
          assetPath = _emojiAssets['Sedih'];
          break;
        case 3:
          assetPath = _emojiAssets['Biasa aja'];
          break;
        case 4:
          assetPath = _emojiAssets['Baik'];
          break;
        case 5:
          assetPath = _emojiAssets['Sangat Baik'];
          break;
      }
      if (assetPath == null) return const SizedBox.shrink();
      return Image.asset(assetPath, width: 28);
    },
  );

  SideTitles _bottomTitles() => SideTitles(
    showTitles: true,
    reservedSize: 30,
    getTitlesWidget: (value, meta) {
      String text = '';
      switch (value.toInt()) {
        case 0:
          text = '1';
          break;
        case 1:
          text = '7';
          break;
        case 2:
          text = '14';
          break;
        case 3:
          text = '21';
          break;
        case 4:
          text = '28';
          break;
        case 5:
          text = '30';
          break;
        case 6:
          text = '31';
          break;
      }
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(
          text,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      );
    },
  );

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/IMG-08.png', height: 150),
            const SizedBox(height: 16),
            Text(
              'Data Statistik Masih Kosong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Isi catatan mood harianmu untuk melihat statistiknya di sini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
