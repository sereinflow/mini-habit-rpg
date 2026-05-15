import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/utils/constants.dart';

/// Habit CRUD — local demo storage (no Firestore).
class HabitService {
  HabitService({DemoDataStore? store}) : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;

  Stream<List<Habit>> watchHabits(String userId) {
    final controller = _store.habitController(userId);
    Future.microtask(() => _store.pushHabitsToStream(userId));
    return controller.stream;
  }

  Future<Habit> addHabit({
    required String userId,
    required String title,
  }) async {
    await _store.ensureLoaded();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final habit = Habit(
      id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title.trim(),
      completed: false,
      xpReward: AppConstants.defaultHabitXp,
    );
    _store.habitsByUser.putIfAbsent(userId, () => []).add(habit);
    await _store.emitHabits(userId);
    return habit;
  }

  Future<void> updateHabit(Habit habit) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final list = _store.habitsFor(habit.userId);
    final index = list.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      list[index] = habit;
      await _store.emitHabits(habit.userId);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    for (final entry in _store.habitsByUser.entries) {
      final had = entry.value.any((h) => h.id == habitId);
      if (!had) continue;
      entry.value.removeWhere((h) => h.id == habitId);
      await _store.emitHabits(entry.key);
      return;
    }
  }
}
