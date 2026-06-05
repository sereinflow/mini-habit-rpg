/// A generated daily quest with XP and coin rewards.
class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.userId,
    required this.title,
    required this.xpReward,
    required this.coinReward,
    required this.completed,
    required this.questDate,
  });

  final String id;
  final String userId;
  final String title;
  final int xpReward;
  final int coinReward;
  final bool completed;
  final String questDate;

  DailyQuest copyWith({bool? completed}) {
    return DailyQuest(
      id: id,
      userId: userId,
      title: title,
      xpReward: xpReward,
      coinReward: coinReward,
      completed: completed ?? this.completed,
      questDate: questDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'xp_reward': xpReward,
      'coin_reward': coinReward,
      'completed': completed,
      'quest_date': questDate,
    };
  }

  factory DailyQuest.fromMap(String id, Map<String, dynamic> map) {
    return DailyQuest(
      id: id,
      userId: map['user_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      xpReward: map['xp_reward'] as int? ?? 50,
      coinReward: map['coin_reward'] as int? ?? 10,
      completed: map['completed'] as bool? ?? false,
      questDate: map['quest_date'] as String? ?? '',
    );
  }
}
