import 'dart:math';

import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/models/quest_type.dart';
import 'package:mini_habit_rpg/utils/xp_calculator.dart';

/// Generates daily quests tailored to the player's current mood.
class DailyQuestGenerator {
  DailyQuestGenerator._();

  static const _motivated = [
    _QuestTemplate('Long study session (60 min)', 100, 20, QuestType.challenge),
    _QuestTemplate('Challenging workout', 95, 19, QuestType.challenge),
    _QuestTemplate('Complete 3 hard habits', 90, 18, QuestType.challenge),
    _QuestTemplate('45-minute deep focus block', 85, 17, QuestType.challenge),
  ];

  static const _tired = [
    _QuestTemplate('Read 5 pages', 30, 6, QuestType.normal),
    _QuestTemplate('Drink a glass of water', 25, 5, QuestType.normal),
    _QuestTemplate('5-minute stretch', 35, 7, QuestType.normal),
    _QuestTemplate('Take a short rest break', 20, 4, QuestType.normal),
  ];

  static const _stressed = [
    _QuestTemplate('Meditate for 10 minutes', 45, 9, QuestType.wellness),
    _QuestTemplate('Deep breathing exercise', 35, 7, QuestType.wellness),
    _QuestTemplate('Write in your journal', 50, 10, QuestType.wellness),
    _QuestTemplate('Take a calming walk', 40, 8, QuestType.wellness),
  ];

  static const _happy = [
    _QuestTemplate('Extra XP sprint — 5 habits', 120, 25, QuestType.bonus),
    _QuestTemplate('Creative side project', 75, 15, QuestType.bonus),
    _QuestTemplate('Share a win with a friend', 55, 12, QuestType.bonus),
    _QuestTemplate('Bonus double-XP habit', 80, 16, QuestType.bonus),
  ];

  /// Primary quest types shown for each mood.
  static QuestType primaryTypeFor(Mood mood) {
    switch (mood) {
      case Mood.motivated:
        return QuestType.challenge;
      case Mood.tired:
        return QuestType.normal;
      case Mood.stressed:
        return QuestType.wellness;
      case Mood.happy:
        return QuestType.bonus;
    }
  }

  static List<_QuestTemplate> _poolFor(Mood mood) {
    switch (mood) {
      case Mood.motivated:
        return _motivated;
      case Mood.tired:
        return _tired;
      case Mood.stressed:
        return _stressed;
      case Mood.happy:
        return _happy;
    }
  }

  /// Generates 3 mood-specific quests (hard / easy / wellness / bonus).
  static List<DailyQuest> generateForMood({
    required String userId,
    required Mood mood,
    required Random random,
  }) {
    final today = XpCalculator.todayKey();
    final pool = List<_QuestTemplate>.from(_poolFor(mood))..shuffle(random);

    return pool.take(3).map((t) {
      return DailyQuest(
        id: 'quest_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(99999)}',
        userId: userId,
        title: t.title,
        xpReward: t.xpReward,
        coinReward: t.coinReward,
        completed: false,
        questDate: today,
        questType: t.questType,
        mood: mood,
      );
    }).toList();
  }

  /// First load — generate if mood known, otherwise default to motivated.
  static List<DailyQuest> generate({
    required String userId,
    required Random random,
    Mood? mood,
  }) =>
      generateForMood(
        userId: userId,
        mood: mood ?? Mood.motivated,
        random: random,
      );
}

class _QuestTemplate {
  const _QuestTemplate(
    this.title,
    this.xpReward,
    this.coinReward,
    this.questType,
  );

  final String title;
  final int xpReward;
  final int coinReward;
  final QuestType questType;
}
