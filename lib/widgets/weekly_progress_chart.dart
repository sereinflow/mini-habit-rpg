import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Bar chart showing habits completed per day this week.
class WeeklyProgressChart extends StatelessWidget {
  const WeeklyProgressChart({super.key, required this.habits});

  final List<Habit> habits;

  List<int> _weeklyCounts() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final counts = List<int>.filled(7, 0);

    for (final habit in habits) {
      final at = habit.completedAt;
      if (at == null || !habit.completed) continue;
      final dayIndex = at.difference(
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      ).inDays;
      if (dayIndex >= 0 && dayIndex < 7) counts[dayIndex]++;
    }
    return counts;
  }

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final counts = _weeklyCounts();
    final maxCount = counts.reduce((a, b) => a > b ? a : b).clamp(1, 999);
    final accent = Theme.of(context).colorScheme.primary;

    return RpgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Habits completed per day',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final height = (counts[i] / maxCount) * 90;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${counts[i]}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: height.clamp(4, 90),
                          decoration: BoxDecoration(
                            color: accent.withValues(
                              alpha: counts[i] > 0 ? 0.9 : 0.2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _labels[i],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
