import 'package:mini_habit_rpg/models/user_profile.dart';

/// Result after applying XP from a completed habit.
class XpResult {
  const XpResult({
    required this.profile,
    required this.leveledUp,
    required this.xpGained,
  });

  final UserProfile profile;
  final bool leveledUp;
  final int xpGained;
}

/// Simple RPG leveling: XP fills bar; overflow levels up the character.
class XpCalculator {
  XpCalculator._();

  static XpResult applyXp(UserProfile profile, int xpGained) {
    var level = profile.level;
    var xp = profile.xp + xpGained;
    var leveledUp = false;

    while (xp >= level * 100) {
      xp -= level * 100;
      level++;
      leveledUp = true;
    }

    return XpResult(
      profile: profile.copyWith(level: level, xp: xp),
      leveledUp: leveledUp,
      xpGained: xpGained,
    );
  }

  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Updates streak when user completes a habit for the first time today.
  static UserProfile updateStreak(UserProfile profile) {
    final today = todayKey();
    final last = profile.lastActiveDate;

    if (last == today) {
      return profile;
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    final newStreak = last == yesterdayKey ? profile.streak + 1 : 1;

    return profile.copyWith(streak: newStreak, lastActiveDate: today);
  }
}
