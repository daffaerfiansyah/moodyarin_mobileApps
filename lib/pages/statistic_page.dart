import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  // Tanggal statis untuk tampilan AppBar
  DateTime _currentDate = DateTime.now();

  // Fungsi navigasi bulan (logika UI saja untuk saat ini)
  String get formattedMonthYear {
    return DateFormat('MMMM yyyy', 'id_ID').format(_currentDate);
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  // --- DATA STATIS UNTUK UI SLICING ---

  // Data untuk Line Chart (Sumbu X: 0=M1, 1=M2, dst. Sumbu Y: 1=Sangat Sedih, 5=Sangat Baik)
  final List<FlSpot> _lineChartSpots = const [
    FlSpot(0, 3.5), // Data untuk tgl 1
    FlSpot(1, 4.0), // Data untuk tgl 7
    FlSpot(2, 2.0), // Data untuk tgl 14
    FlSpot(3, 3.0), // Data untuk tgl 21
    FlSpot(4, 4.5), // Data untuk tgl 28
    FlSpot(5, 4.2), // Data untuk tgl 30
    FlSpot(6, 5.0), // Data untuk tgl 31
  ];

  // Data untuk Radial Gauge (distribusi mood dalam sebulan)
  final List<PieChartSectionData> _radialSections = [
    PieChartSectionData(
      color: Color(0xFF34D399),
      value: 25,
      title: '',
      radius: 25,
    ), // Sangat Baik
    PieChartSectionData(
      color: Color(0xFF60A5FA),
      value: 30,
      title: '',
      radius: 25,
    ), // Baik
    PieChartSectionData(
      color: Color(0xFFFBBF24),
      value: 20,
      title: '',
      radius: 25,
    ), // Biasa aja
    PieChartSectionData(
      color: Color(0xFFF87171),
      value: 15,
      title: '',
      radius: 25,
    ), // Sedih
    PieChartSectionData(
      color: Color(0xFFEF4444),
      value: 10,
      title: '',
      radius: 25,
    ), // Sangat Sedih
  ];

  // Aset emoji untuk legenda
  static const Map<String, String> _emojiAssets = {
    'Sangat Baik': 'assets/Emoji-5.png',
    'Baik': 'assets/Emoji-4.png',
    'Biasa aja': 'assets/Emoji-3.png',
    'Sedih': 'assets/Emoji-2.png',
    'Sangat Sedih': 'assets/Emoji-1.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
              onPressed: _previousMonth,
            ),
            Expanded(
              child: Center(
                child: Text(
                  formattedMonthYear,
                  style: GoogleFonts.jua(
                    fontSize: 24,
                    color: Colors.indigo.shade900,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
              onPressed: _nextMonth,
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
              'Semangat!',
              const Color(0xFF4F46E5),
            ),
            const SizedBox(height: 12),
            _buildLineChartCard(),
            const SizedBox(height: 28),
            _buildSectionHeader(
              'Perhitungan Mood',
              'Ayo tingkatkan bahagiamu!',
              const Color(0xFF4F46E5),
            ),
            const SizedBox(height: 12),
            _buildRadialGaugeCard(),
          ],
        ),
      ),
    );
  }

  // Widget untuk judul setiap seksi
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

  // Widget untuk kartu Grafik Garis (Line Chart)
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
            maxX: 6, // 4 minggu (0, 1, 2, 3)
            minY: 1,
            maxY: 5, // 5 level mood
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

  // Widget untuk kartu Grafik Lingkaran (Radial Gauge)
  Widget _buildRadialGaugeCard() {
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
            height: 150,
            child: PieChart(
              PieChartData(
                sections: _radialSections,
                pieTouchData: PieTouchData(enabled: false),
                startDegreeOffset: -90, // Mulai dari atas
                centerSpaceRadius: 60,
                sectionsSpace: 4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legenda Emoji
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(_emojiAssets['Sangat Sedih']!, width: 50),
              Image.asset(_emojiAssets['Sedih']!, width: 50),
              Image.asset(_emojiAssets['Biasa aja']!, width: 50),
              Image.asset(_emojiAssets['Baik']!, width: 50),
              Image.asset(_emojiAssets['Sangat Baik']!, width: 50),
            ],
          ),
        ],
      ),
    );
  }

  // --- Konfigurasi Label untuk Grafik ---

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
