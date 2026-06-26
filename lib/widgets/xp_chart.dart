import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Visual XP progression toward next level and milestones.
class XpChart extends StatelessWidget {
  const XpChart({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final milestones = [
      _Milestone('Current Level', profile.level, profile.xp, profile.xpToNextLevel),
      _Milestone('Total Earned', profile.level, profile.totalXpEarned, profile.totalXpEarned + 100),
    ];

    return RpgCard(
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'XP Progress',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Level ${profile.level} → ${profile.level + 1}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          const SizedBox(height: 16),
          ...milestones.map((m) {
            final progress = m.max > 0 ? (m.current / m.max).clamp(0.0, 1.0) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.label),
                      Text(
                        '${m.current} / ${m.max} XP',
                        style: TextStyle(color: accent, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: accent,
                    ),
                  ),
                ],
              ),
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _XpStat(label: 'This Level', value: '${profile.xp}'),
              _XpStat(label: 'To Next', value: '${profile.xpToNextLevel - profile.xp}'),
              _XpStat(label: 'All Time', value: '${profile.totalXpEarned}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Milestone {
  const _Milestone(this.label, this.level, this.current, this.max);
  final String label;
  final int level;
  final int current;
  final int max;
}

class _XpStat extends StatelessWidget {
  const _XpStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
