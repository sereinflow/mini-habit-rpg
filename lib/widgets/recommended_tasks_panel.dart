import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/theme/mood_theme.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Lists mood-specific recommended tasks on the quest board.
class RecommendedTasksPanel extends StatelessWidget {
  const RecommendedTasksPanel({
    super.key,
    required this.theme,
  });

  final MoodThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: RpgCard(
        key: ValueKey(theme.questSectionTitle),
        accentColor: theme.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MoodAnimatedIcon(
                  icon: theme.icon,
                  color: theme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  theme.questSectionTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: theme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...theme.recommendedTasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: theme.secondary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(task)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
