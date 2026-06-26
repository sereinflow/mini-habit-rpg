import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/theme/mood_theme.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Inline mood picker — updates theme, quests, and recommendations on tap.
class MoodSelector extends StatefulWidget {
  const MoodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.moodTheme,
  });

  final Mood? selected;
  final ValueChanged<Mood> onSelected;
  final MoodThemeData? moodTheme;

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  @override
  Widget build(BuildContext context) {
    final active = widget.selected ?? Mood.motivated;
    final theme = widget.moodTheme ?? MoodTheme.forMood(active);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      child: RpgCard(
        accentColor: theme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MoodAnimatedIcon(
                  icon: theme.icon,
                  color: theme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'How are you feeling?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Text(
                theme.motivationalText,
                key: ValueKey(theme.motivationalText),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Mood.values.map((mood) {
                final isSelected = widget.selected == mood;
                final chipTheme = MoodTheme.forMood(mood);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ChoiceChip(
                    label: Text('${mood.emoji} ${mood.label}'),
                    selected: isSelected,
                    onSelected: (_) => widget.onSelected(mood),
                    selectedColor: chipTheme.primary.withValues(alpha: 0.35),
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    side: BorderSide(
                      color:
                          isSelected ? chipTheme.primary : Colors.white24,
                      width: isSelected ? 2 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
