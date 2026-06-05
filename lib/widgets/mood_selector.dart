import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Horizontal mood picker that affects habit recommendations.
class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final Mood? selected;
  final ValueChanged<Mood> onSelected;

  @override
  Widget build(BuildContext context) {
    return RpgCard(
      accentColor: Theme.of(context).colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (selected != null) ...[
            const SizedBox(height: 4),
            Text(
              selected!.hint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Mood.values.map((mood) {
              final isSelected = selected == mood;
              return ChoiceChip(
                label: Text('${mood.emoji} ${mood.label}'),
                selected: isSelected,
                onSelected: (_) => onSelected(mood),
                selectedColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
