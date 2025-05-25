class MoodEntry {
  final DateTime date;
  final String mood;
  final String note;

  MoodEntry({required this.date, required this.mood, required this.note});

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(), // pastikan disimpan dalam format ISO
      'mood': mood,
      'note': note,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']), // ← dikonversi ke DateTime
      mood: json['mood'],
      note: json['note'],
    );
  }
}
