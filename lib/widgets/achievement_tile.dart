import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/achievement.dart';

/// Achievement card for profile and stats screens.
class AchievementTile extends StatelessWidget {
  const AchievementTile({
    super.key,
    required this.type,
    required this.unlocked,
  });

  final AchievementType type;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: unlocked
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.04),
      child: ListTile(
        leading: Icon(
          unlocked ? Icons.emoji_events : Icons.lock_outline,
          color: unlocked ? Colors.amber : Colors.white38,
        ),
        title: Text(
          type.name,
          style: TextStyle(
            color: unlocked ? null : Colors.white54,
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(type.description),
        trailing: unlocked
            ? Text(
                '+${type.coinReward}🪙',
                style: const TextStyle(color: Colors.amber),
              )
            : null,
      ),
    );
  }
}
