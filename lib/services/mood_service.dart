import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moodyarin/models/mood_entry.dart';

class MoodService {
  static Future<void> saveMood(MoodEntry entry) async {
    final response =
        await Supabase.instance.client
            .from('mood_entries')
            .insert({
              'date': entry.date.toIso8601String(), // format 'yyyy-MM-dd'
              'mood': entry.mood,
              'note': entry.note,
            })
            .select()
            .single();

    if (response == null) {
      throw Exception('Insert gagal');
    }
  }
}
