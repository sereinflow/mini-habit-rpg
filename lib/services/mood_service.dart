import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/models/mood_entry.dart';
import 'package:mini_habit_rpg/repositories/mood_repository.dart';

/// Mood selection and history.
class MoodService {
  MoodService({MoodRepository? repository})
      : _repository = repository ?? MoodRepository();

  final MoodRepository _repository;

  Future<MoodEntry> recordMood({
    required String userId,
    required Mood mood,
  }) =>
      _repository.recordMood(userId: userId, mood: mood);

  Mood? currentMood(String userId) => _repository.currentMood(userId);

  Stream<List<MoodEntry>> watchHistory(String userId) =>
      _repository.watchHistory(userId);
}
