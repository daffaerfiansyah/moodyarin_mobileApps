class MoodEntry {
  // TAMBAHKAN PROPERTI 'id'
  final String id;
  final DateTime date;
  final String mood;
  final String note;

  // TAMBAHKAN 'id' DI CONSTRUCTOR
  MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'id' tidak perlu dikirim saat insert karena dibuat otomatis oleh Supabase
      'date': date.toIso8601String(),
      'mood': mood,
      'note': note,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      // AMBIL 'id' DARI JSON RESPONSE
      id: json['id'].toString(),
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      note: json['note'],
    );
  }
}