import 'package:flutter/material.dart';

/// Animated XP bar for character progression.
class XpProgressBar extends StatelessWidget {
  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.maxXp,
    required this.level,
    this.height = 14,
  });

  final int currentXp;
  final int maxXp;
  final int level;
  final double height;

  @override
  Widget build(BuildContext context) {
    final progress = maxXp > 0 ? (currentXp / maxXp).clamp(0.0, 1.0) : 0.0;
    final accent = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            Text(
              '$currentXp / $maxXp XP',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Container(color: Colors.white12),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.6)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
