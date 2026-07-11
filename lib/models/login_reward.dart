class LoginReward {
  const LoginReward({
    required this.dayIndex,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.coinReward,
    this.itemIdReward,
    required this.icon,
  });

  final int dayIndex;
  final String title;
  final String description;
  final int xpReward;
  final int coinReward;
  final String? itemIdReward;
  final String icon;

  static const List<LoginReward> weeklyRewards = [
    LoginReward(
      dayIndex: 1,
      title: 'Day 1',
      description: '+15 Coins',
      xpReward: 0,
      coinReward: 15,
      icon: '🪙',
    ),
    LoginReward(
      dayIndex: 2,
      title: 'Day 2',
      description: '+50 XP',
      xpReward: 50,
      coinReward: 0,
      icon: '⚡',
    ),
    LoginReward(
      dayIndex: 3,
      title: 'Day 3',
      description: '+30 Coins',
      xpReward: 0,
      coinReward: 30,
      icon: '🪙',
    ),
    LoginReward(
      dayIndex: 4,
      title: 'Day 4',
      description: '+100 XP',
      xpReward: 100,
      coinReward: 0,
      icon: '⚡',
    ),
    LoginReward(
      dayIndex: 5,
      title: 'Day 5',
      description: 'Elixir of Wisdom',
      xpReward: 0,
      coinReward: 0,
      itemIdReward: 'consumable_xp_boost',
      icon: '🧪',
    ),
    LoginReward(
      dayIndex: 6,
      title: 'Day 6',
      description: 'Streak Aegis',
      xpReward: 0,
      coinReward: 0,
      itemIdReward: 'consumable_streak_shield',
      icon: '🛡️',
    ),
    LoginReward(
      dayIndex: 7,
      title: 'Day 7',
      description: 'Angel Wings & Coins',
      xpReward: 0,
      coinReward: 100,
      itemIdReward: 'acc_wings',
      icon: '🪽',
    ),
  ];

  static LoginReward getByDay(int day) {
    return weeklyRewards.firstWhere(
      (r) => r.dayIndex == day,
      orElse: () => weeklyRewards[0],
    );
  }
}
