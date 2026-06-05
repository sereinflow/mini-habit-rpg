import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/utils/personality_calculator.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Adaptive personality breakdown — Scholar / Warrior / Artist percentages.
class PersonalityChart extends StatelessWidget {
  const PersonalityChart({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final breakdown = PersonalityCalculator.breakdown(profile);

    return RpgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personality Evolution',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Earned from habit categories',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          const SizedBox(height: 16),
          _TraitBar(
            label: 'Scholar',
            emoji: '📚',
            percent: breakdown.scholarPercent,
            color: const Color(0xFF5C7CFA),
          ),
          const SizedBox(height: 10),
          _TraitBar(
            label: 'Warrior',
            emoji: '⚔️',
            percent: breakdown.warriorPercent,
            color: const Color(0xFFE03131),
          ),
          const SizedBox(height: 10),
          _TraitBar(
            label: 'Artist',
            emoji: '🎨',
            percent: breakdown.artistPercent,
            color: const Color(0xFFF59F00),
          ),
        ],
      ),
    );
  }
}

class _TraitBar extends StatelessWidget {
  const _TraitBar({
    required this.label,
    required this.emoji,
    required this.percent,
    required this.color,
  });

  final String label;
  final String emoji;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$emoji $label'),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: color,
          ),
        ),
      ],
    );
  }
}
