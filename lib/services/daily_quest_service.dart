import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/repositories/daily_quest_repository.dart';

/// Daily quest operations.
class DailyQuestService {
  DailyQuestService({DailyQuestRepository? repository})
      : _repository = repository ?? DailyQuestRepository();

  final DailyQuestRepository _repository;

  Stream<List<DailyQuest>> watchQuests(String userId) =>
      _repository.watch(userId);

  Future<List<DailyQuest>> ensureTodayQuests(
    String userId, {
    Mood? mood,
  }) =>
      _repository.ensureTodayQuests(userId, mood: mood);

  Future<List<DailyQuest>> regenerateForMood(String userId, Mood mood) =>
      _repository.regenerateForMood(userId, mood);

  Future<void> updateQuest(DailyQuest quest) => _repository.update(quest);
}
