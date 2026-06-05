import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/repositories/daily_quest_repository.dart';

/// Daily quest operations.
class DailyQuestService {
  DailyQuestService({DailyQuestRepository? repository})
      : _repository = repository ?? DailyQuestRepository();

  final DailyQuestRepository _repository;

  Stream<List<DailyQuest>> watchQuests(String userId) =>
      _repository.watch(userId);

  Future<List<DailyQuest>> ensureTodayQuests(String userId) =>
      _repository.ensureTodayQuests(userId);

  Future<void> updateQuest(DailyQuest quest) => _repository.update(quest);
}
