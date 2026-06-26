import 'package:mini_habit_rpg/models/personality_archetype.dart';

/// Habit categories that feed the adaptive personality system.
enum HabitCategory {
  study('Study', '📚', PersonalityArchetype.scholar),
  fitness('Fitness', '💪', PersonalityArchetype.warrior),
  health('Health', '💚', PersonalityArchetype.warrior),
  creative('Creativity', '🎨', PersonalityArchetype.artist),
  social('Social', '🤝', PersonalityArchetype.artist);

  const HabitCategory(this.label, this.emoji, this.archetype);

  final String label;
  final String emoji;
  final PersonalityArchetype archetype;

  static HabitCategory fromString(String? value) {
    if (value == null) return HabitCategory.study;
    return HabitCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => HabitCategory.study,
    );
  }
}
