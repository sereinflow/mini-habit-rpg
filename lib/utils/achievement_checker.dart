import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';

/// Evaluates which achievements should unlock based on player progress.
class AchievementChecker {
  AchievementChecker._();

  static List<AchievementType> checkUnlocks({
    required UserProfile profile,
    required int totalHabitsCompleted,
    required Set<String> alreadyUnlocked,
  }) {
    final newlyUnlocked = <AchievementType>[];

    void tryUnlock(AchievementType type, bool condition) {
      if (condition && !alreadyUnlocked.contains(type.id)) {
        newlyUnlocked.add(type);
      }
    }

    tryUnlock(AchievementType.firstHabit, totalHabitsCompleted >= 1);
    tryUnlock(AchievementType.level5, profile.level >= 5);
    tryUnlock(AchievementType.streak3, profile.streak >= 3);
    tryUnlock(AchievementType.habits10, totalHabitsCompleted >= 10);

    return newlyUnlocked;
  }
}
