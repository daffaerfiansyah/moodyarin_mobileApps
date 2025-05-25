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

  static Future<void> updateMood(MoodEntry entry) async {
    final response = await Supabase.instance.client
        .from('mood_entries')
        .update({
          'mood': entry.mood,
          'note': entry.note,
          'date': entry.date.toIso8601String(),
        })
        .eq('id', entry.id); // Targetkan baris data dengan ID yang cocok

    if (response != null && response.error != null) {
      throw Exception('Update gagal: ${response.error!.message}');
    }
  }

  static Future<void> deleteMood(String id) async {
    final response = await Supabase.instance.client
        .from('mood_entries')
        .delete()
        .eq('id', id); // Targetkan baris data dengan ID yang cocok

    if (response != null && response.error != null) {
      throw Exception('Delete gagal: ${response.error!.message}');
    }
  }
}
