import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// XP earned breakdown by habit category.
class CategoryAnalysisChart extends StatelessWidget {
  const CategoryAnalysisChart({super.key, required this.habits});

  final List<Habit> habits;

  Map<HabitCategory, int> _xpByCategory() {
    final map = <HabitCategory, int>{};
    for (final cat in HabitCategory.values) {
      map[cat] = 0;
    }
    for (final habit in habits.where((h) => h.completed)) {
      map[habit.category] = (map[habit.category] ?? 0) + habit.xpReward;
    }
    return map;
  }

  static const _colors = {
    HabitCategory.study: Color(0xFF5C7CFA),
    HabitCategory.fitness: Color(0xFFE03131),
    HabitCategory.health: Color(0xFF20C997),
    HabitCategory.creative: Color(0xFFF59F00),
    HabitCategory.social: Color(0xFF9775FA),
  };

  @override
  Widget build(BuildContext context) {
    final xpMap = _xpByCategory();
    final total = xpMap.values.fold<int>(0, (a, b) => a + b);
    final maxXp = xpMap.values.fold<int>(0, (a, b) => a > b ? a : b).clamp(1, 999);

    return RpgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Analysis',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'XP earned by habit type',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          const SizedBox(height: 16),
          if (total == 0)
            const Text('Complete habits to see category breakdown.')
          else
            ...HabitCategory.values.map((cat) {
              final xp = xpMap[cat] ?? 0;
              final color = _colors[cat] ?? Colors.grey;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${cat.emoji} ${cat.label}'),
                        Text(
                          '$xp XP (${total > 0 ? (xp / total * 100).toStringAsFixed(0) : 0}%)',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: xp / maxXp,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
