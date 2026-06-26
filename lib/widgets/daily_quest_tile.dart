import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/daily_quest.dart';

/// Single daily quest row with type badge and rewards.
class DailyQuestTile extends StatelessWidget {
  const DailyQuestTile({
    super.key,
    required this.quest,
    required this.onComplete,
    this.highlighted = false,
    this.accentColor,
  });

  final DailyQuest quest;
  final VoidCallback onComplete;
  final bool highlighted;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ??
        (highlighted
            ? quest.questType.color
            : Theme.of(context).colorScheme.secondary);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: quest.completed
          ? Colors.white.withValues(alpha: 0.04)
          : highlighted
              ? accent.withValues(alpha: 0.08)
              : null,
      shape: highlighted
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: accent.withValues(alpha: 0.5)),
            )
          : null,
      child: ListTile(
        leading: GestureDetector(
          onTap: quest.completed ? null : onComplete,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: quest.completed
                  ? accent
                  : Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: quest.completed ? accent : Colors.white24,
                width: 2,
              ),
            ),
            child: quest.completed
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : Text(
                    quest.questType.emoji,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                quest.title,
                style: TextStyle(
                  decoration:
                      quest.completed ? TextDecoration.lineThrough : null,
                  color: quest.completed ? Colors.white54 : null,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: quest.questType.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                quest.questType.label,
                style: TextStyle(
                  fontSize: 10,
                  color: quest.questType.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '+${quest.xpReward} XP · +${quest.coinReward} coins',
          style: TextStyle(color: accent.withValues(alpha: 0.8)),
        ),
        trailing: quest.completed
            ? const Icon(Icons.verified, color: Colors.greenAccent, size: 20)
            : null,
      ),
    );
  }
}
