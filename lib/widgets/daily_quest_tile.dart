import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/daily_quest.dart';

/// Single daily quest row with rewards.
class DailyQuestTile extends StatelessWidget {
  const DailyQuestTile({
    super.key,
    required this.quest,
    required this.onComplete,
  });

  final DailyQuest quest;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: quest.completed
          ? Colors.white.withValues(alpha: 0.04)
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
                : const Icon(Icons.auto_awesome, color: Colors.white38, size: 20),
          ),
        ),
        title: Text(
          quest.title,
          style: TextStyle(
            decoration:
                quest.completed ? TextDecoration.lineThrough : null,
            color: quest.completed ? Colors.white54 : null,
          ),
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
