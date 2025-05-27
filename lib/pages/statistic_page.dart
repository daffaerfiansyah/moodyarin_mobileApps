import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  DateTime _currentDate = DateTime.now();
  // Replaced with _touchedIndex to handle interaction for both chart and legend
  int? _touchedIndex;

  String get formattedMonthYear {
    return DateFormat('MMMM yyyy', 'id_ID').format(_currentDate);
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _touchedIndex = null; // Reset selection on month change
    });
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _touchedIndex = null; // Reset selection on month change
    });
  }

  // --- STATIC DATA FOR UI SLICING ---

  // Data for Line Chart
  final List<FlSpot> _lineChartSpots = const [
    FlSpot(0, 3.5),
    FlSpot(1, 4.0),
    FlSpot(2, 2.0),
    FlSpot(3, 3.0),
    FlSpot(4, 4.5),
    FlSpot(5, 4.2),
    FlSpot(6, 5.0),
  ];

  // Data for Radial Gauge (mood distribution in a month)
  final Map<String, int> _moodDistribution = {
    'Sangat Baik': 10,
    'Baik': 8,
    'Biasa aja': 6,
    'Sedih': 4,
    'Sangat Sedih': 2,
  };

  // Emoji assets for the legend
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              'Grafik Mood',
              'Dalam Satu Bulan',
              const Color(0xFF4F46E5),
            ),
            const SizedBox(height: 12),
            _buildLineChartCard(),
            const SizedBox(height: 28),
            _buildSectionHeader(
              'Perhitungan Mood',
              'Sentuh Mood untuk melihat detail jumlah!',
              const Color(0xFF4F46E5),
            ),
            const SizedBox(height: 12),
            _buildRadialGaugeCard(),
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

  Widget _buildLineChartCard() {
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
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine:
                  (value) =>
                      const FlLine(color: Color(0xffe7e8ec), strokeWidth: 1),
              getDrawingVerticalLine:
                  (value) =>
                      const FlLine(color: Color(0xffe7e8ec), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: _leftTitles()),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: _bottomTitles()),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xffe7e8ec), width: 1),
            ),
            minX: 0,
            maxX: 6,
            minY: 1,
            maxY: 5,
            lineBarsData: [
              LineChartBarData(
                spots: _lineChartSpots,
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

  Widget _buildRadialGaugeCard() {
    // Get the keys to ensure consistent ordering
    final moodKeys = _moodDistribution.keys.toList();
    // Calculate total value for percentage calculation
    final totalValue = _moodDistribution.values.fold(
      0,
      (sum, item) => sum + item,
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
                    pieTouchData: PieTouchData(enabled: false),
                    sections: List.generate(_moodDistribution.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final radius = isTouched ? 35.0 : 25.0;
                      final moodName = moodKeys[i];
                      final value = _moodDistribution[moodName]!;

                      return PieChartSectionData(
                        color: _moodColorMap[moodName],
                        value: value.toDouble(),
                        title: '',
                        radius: radius,
                      );
                    }),
                    startDegreeOffset: -90,
                    centerSpaceRadius: 70,
                    sectionsSpace: 4,
                  ),
                ),
                // Teks di tengah akan tetap berfungsi seperti sebelumnya
                Builder(
                  builder: (context) {
                    if (_touchedIndex == null || totalValue == 0) {
                      return Text(
                        'Presentase',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      );
                    }

                    final moodName = moodKeys[_touchedIndex!];
                    final value = _moodDistribution[moodName]!;
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
                            color: _moodColorMap[moodName],
                          ),
                        ),
                        Text(
                          moodName,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                _emojiAssets.entries
                    .map((entry) {
                      final moodLabel = entry.key;
                      final assetPath = entry.value;

                      final currentIndex = moodKeys.indexOf(moodLabel);
                      final isSelected = _touchedIndex == currentIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _touchedIndex = isSelected ? null : currentIndex;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Opacity(
                              opacity: isSelected ? 1.0 : 0.0,
                              child: Text(
                                '${_moodDistribution[moodLabel]} Hari',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.indigo.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Image.asset(assetPath, width: 50),
                          ],
                        ),
                      );
                    })
                    .toList()
                    .reversed
                    .toList(),
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
}
