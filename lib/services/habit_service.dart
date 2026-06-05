import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/repositories/habit_repository.dart';

/// Habit CRUD — delegates to HabitRepository.
class HabitService {
  HabitService({HabitRepository? repository})
      : _repository = repository ?? HabitRepository();

  final HabitRepository _repository;

  Stream<List<Habit>> watchHabits(String userId) => _repository.watch(userId);

  Future<Habit> addHabit({
    required String userId,
    required String title,
    required HabitCategory category,
  }) =>
      _repository.add(userId: userId, title: title, category: category);

  Future<void> updateHabit(Habit habit) => _repository.update(habit);

  Future<void> deleteHabit(String habitId, String userId) =>
      _repository.delete(habitId, userId);
}
