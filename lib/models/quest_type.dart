import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/mood.dart';

/// Quest difficulty and reward tier.
enum QuestType {
  normal('Normal', '⚔️', Colors.blueGrey),
  challenge('Challenge', '🔥', Colors.deepOrange),
  bonus('Bonus', '⭐', Colors.amber),
  wellness('Wellness', '🌿', Colors.teal);

  const QuestType(this.label, this.emoji, this.color);

  final String label;
  final String emoji;
  final Color color;

  static QuestType fromString(String? value) {
    return QuestType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => QuestType.normal,
    );
  }

  /// Which moods prioritize this quest type.
  static List<QuestType> preferredFor(Mood mood) {
    switch (mood) {
      case Mood.motivated:
        return [QuestType.challenge, QuestType.normal];
      case Mood.tired:
        return [QuestType.normal];
      case Mood.stressed:
        return [QuestType.wellness, QuestType.normal];
      case Mood.happy:
        return [QuestType.bonus, QuestType.normal];
    }
  }
}
