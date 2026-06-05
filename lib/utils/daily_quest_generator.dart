import 'dart:math';

import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/utils/xp_calculator.dart';

/// Generates 1–3 daily quests from a template pool.
class DailyQuestGenerator {
  DailyQuestGenerator._();

  static final _templates = [
    _QuestTemplate('Complete 3 habits', 75, 15),
    _QuestTemplate('Study 30 minutes', 60, 12),
    _QuestTemplate('Drink water 5 times', 40, 8),
    _QuestTemplate('Take a 15-minute walk', 50, 10),
    _QuestTemplate('Write in your journal', 55, 11),
    _QuestTemplate('Meditate for 10 minutes', 45, 9),
    _QuestTemplate('Complete 2 fitness habits', 80, 16),
    _QuestTemplate('Finish a creative task', 65, 13),
  ];

  static List<DailyQuest> generate({
    required String userId,
    required Random random,
  }) {
    final count = 1 + random.nextInt(3);
    final shuffled = List<_QuestTemplate>.from(_templates)..shuffle(random);

    final today = XpCalculator.todayKey();
    return shuffled.take(count).map((t) {
      return DailyQuest(
        id: 'quest_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(9999)}',
        userId: userId,
        title: t.title,
        xpReward: t.xpReward,
        coinReward: t.coinReward,
        completed: false,
        questDate: today,
      );
    }).toList();
  }
}

class _QuestTemplate {
  const _QuestTemplate(this.title, this.xpReward, this.coinReward);

  final String title;
  final int xpReward;
  final int coinReward;
}
