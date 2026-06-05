/// Catalog of unlockable achievements.
enum AchievementType {
  firstHabit('first_habit', 'First Habit', 'Complete your first habit', 50, 25),
  level5('level_5', 'Level 5', 'Reach level 5', 100, 50),
  streak3('streak_3', '3 Day Streak', 'Maintain a 3-day streak', 75, 40),
  habits10('habits_10', '10 Habits Completed', 'Complete 10 habits total', 150, 75);

  const AchievementType(
    this.id,
    this.name,
    this.description,
    this.xpReward,
    this.coinReward,
  );

  final String id;
  final String name;
  final String description;
  final int xpReward;
  final int coinReward;

  static AchievementType? fromId(String? id) {
    if (id == null) return null;
    for (final type in AchievementType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}

/// User's unlocked achievement record.
class UserAchievement {
  const UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementName,
    required this.unlocked,
    this.unlockedAt,
  });

  final String id;
  final String userId;
  final String achievementName;
  final bool unlocked;
  final DateTime? unlockedAt;

  AchievementType? get type => AchievementType.fromId(achievementName);

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'achievement_name': achievementName,
      'unlocked': unlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  factory UserAchievement.fromMap(String id, Map<String, dynamic> map) {
    final unlockedAtRaw = map['unlocked_at'] as String?;
    return UserAchievement(
      id: id,
      userId: map['user_id'] as String? ?? '',
      achievementName: map['achievement_name'] as String? ?? '',
      unlocked: map['unlocked'] as bool? ?? false,
      unlockedAt:
          unlockedAtRaw != null ? DateTime.tryParse(unlockedAtRaw) : null,
    );
  }
}
