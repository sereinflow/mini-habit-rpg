import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/repositories/achievement_repository.dart';
import 'package:mini_habit_rpg/utils/achievement_checker.dart';

/// Reusable achievement framework — checks conditions and unlocks rewards.
class AchievementService {
  AchievementService({AchievementRepository? repository})
      : _repository = repository ?? AchievementRepository();

  final AchievementRepository _repository;

  Stream<List<UserAchievement>> watchAchievements(String userId) =>
      _repository.watch(userId);

  Future<List<AchievementType>> checkAndUnlock({
    required String userId,
    required UserProfile profile,
  }) async {
    final existing = await _repository.getAll(userId);
    final unlockedIds =
        existing.where((a) => a.unlocked).map((a) => a.achievementName).toSet();

    final toUnlock = AchievementChecker.checkUnlocks(
      profile: profile,
      totalHabitsCompleted: profile.totalHabitsCompleted,
      alreadyUnlocked: unlockedIds,
    );

    for (final type in toUnlock) {
      await _repository.unlock(userId: userId, type: type);
    }

    return toUnlock;
  }
}
