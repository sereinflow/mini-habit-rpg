import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/models/mood_entry.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';

/// Mood selection and history persistence.
class MoodRepository {
  MoodRepository({DemoDataStore? store})
      : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;
  final Map<String, Mood> _currentMoodCache = {};

  Future<MoodEntry> recordMood({
    required String userId,
    required Mood mood,
  }) async {
    final entry = MoodEntry(
      id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      mood: mood,
      recordedAt: DateTime.now(),
    );

    _currentMoodCache[userId] = mood;

    if (SupabaseService.isReady) {
      final row = await SupabaseService.client
          .from('mood_history')
          .insert(entry.toMap())
          .select()
          .single();
      return MoodEntry.fromMap(
        row['id'] as String,
        Map<String, dynamic>.from(row),
      );
    }

    _store.moodHistoryByUser.putIfAbsent(userId, () => []).add(entry);
    _store.currentMoodByUser[userId] = mood;
    await _store.emitMoodHistory(userId);
    return entry;
  }

  Mood? currentMood(String userId) {
    return _currentMoodCache[userId] ?? _store.currentMoodByUser[userId];
  }

  Stream<List<MoodEntry>> watchHistory(String userId) {
    if (SupabaseService.isReady) {
      return _watchSupabase(userId);
    }
    final controller = _store.moodController(userId);
    Future.microtask(() => _store.pushMoodHistoryToStream(userId));
    return controller.stream;
  }

  Stream<List<MoodEntry>> _watchSupabase(String userId) async* {
    Future<List<MoodEntry>> fetch() async {
      final rows = await SupabaseService.client
          .from('mood_history')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(30);
      final entries = (rows as List<dynamic>)
          .map((r) => MoodEntry.fromMap(
                r['id'] as String,
                Map<String, dynamic>.from(r as Map),
              ))
          .toList();
      if (entries.isNotEmpty) {
        _currentMoodCache[userId] = entries.first.mood;
      }
      return entries;
    }

    yield await fetch();
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 3));
      yield await fetch();
    }
  }
}
