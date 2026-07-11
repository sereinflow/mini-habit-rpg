import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
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

    // Beginner Achievements
    tryUnlock(AchievementType.firstHabit, totalHabitsCompleted >= 1);
    tryUnlock(AchievementType.level5, profile.level >= 5);

    // Consistency Achievements
    tryUnlock(AchievementType.streak3, profile.streak >= 3);
    tryUnlock(AchievementType.streak10, profile.streak >= 10);
    tryUnlock(AchievementType.habits10, totalHabitsCompleted >= 10);
    tryUnlock(AchievementType.habits50, totalHabitsCompleted >= 50);

    // Personality Achievements
    tryUnlock(
      AchievementType.scholarArchetype,
      profile.archetype == PersonalityArchetype.scholar,
    );
    tryUnlock(
      AchievementType.warriorArchetype,
      profile.archetype == PersonalityArchetype.warrior,
    );
    tryUnlock(
      AchievementType.artistArchetype,
      profile.archetype == PersonalityArchetype.artist,
    );

    return newlyUnlocked;
  }
}
