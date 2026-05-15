import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';

/// Small badge showing the user's personality path.
class ArchetypeBadge extends StatelessWidget {
  const ArchetypeBadge({super.key, required this.archetype});

  final PersonalityArchetype archetype;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentFor(archetype);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(archetype.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            archetype.label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
