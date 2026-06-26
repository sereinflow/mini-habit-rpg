import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/models/mood.dart';

/// Filters and ranks habits based on the player's current mood.
class MoodRecommender {
  MoodRecommender._();

  static List<Habit> recommend(List<Habit> habits, Mood mood) {
    final incomplete = habits.where((h) => !h.completed).toList();
    if (incomplete.isEmpty) return [];

    switch (mood) {
      case Mood.motivated:
        return List<Habit>.from(incomplete)
          ..sort((a, b) => b.xpReward.compareTo(a.xpReward));
      case Mood.tired:
        return List<Habit>.from(incomplete)
          ..sort((a, b) => a.xpReward.compareTo(b.xpReward));
      case Mood.happy:
        return _filterByCategories(
          incomplete,
          [HabitCategory.creative, HabitCategory.social],
        );
      case Mood.stressed:
        return _filterByCategories(
          incomplete,
          [HabitCategory.health, HabitCategory.fitness],
        );
    }
  }

  static List<Habit> _filterByCategories(
    List<Habit> habits,
    List<HabitCategory> preferred,
  ) {
    final preferredHabits =
        habits.where((h) => preferred.contains(h.category)).toList();
    if (preferredHabits.isNotEmpty) return preferredHabits;
    return habits;
  }
}
