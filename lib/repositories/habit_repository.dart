import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';
import 'package:mini_habit_rpg/utils/constants.dart';

/// Habit CRUD — demo store or Supabase `habits` table.
class HabitRepository {
  HabitRepository({DemoDataStore? store})
      : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;

  Stream<List<Habit>> watch(String userId) {
    if (SupabaseService.isReady) {
      return _watchSupabase(userId);
    }
    final controller = _store.habitController(userId);
    Future.microtask(() => _store.pushHabitsToStream(userId));
    return controller.stream;
  }

  Future<Habit> add({
    required String userId,
    required String title,
    required HabitCategory category,
  }) async {
    final habit = Habit(
      id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title.trim(),
      category: category,
      completed: false,
      xpReward: AppConstants.defaultHabitXp,
      createdAt: DateTime.now(),
    );

    if (SupabaseService.isReady) {
      final row = await SupabaseService.client
          .from('habits')
          .insert(habit.toMap())
          .select()
          .single();
      return Habit.fromMap(row['id'] as String, Map<String, dynamic>.from(row));
    }

    await _store.ensureLoaded();
    _store.habitsByUser.putIfAbsent(userId, () => []).add(habit);
    await _store.emitHabits(userId);
    return habit;
  }

  Future<void> update(Habit habit) async {
    if (SupabaseService.isReady) {
      await SupabaseService.client
          .from('habits')
          .update(habit.toMap())
          .eq('id', habit.id);
      return;
    }

    final list = _store.habitsFor(habit.userId);
    final index = list.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      list[index] = habit;
      await _store.emitHabits(habit.userId);
    }
  }

  Future<void> delete(String habitId, String userId) async {
    if (SupabaseService.isReady) {
      await SupabaseService.client.from('habits').delete().eq('id', habitId);
      return;
    }

    final list = _store.habitsFor(userId);
    list.removeWhere((h) => h.id == habitId);
    await _store.emitHabits(userId);
  }

  Stream<List<Habit>> _watchSupabase(String userId) async* {
    Future<List<Habit>> fetch() async {
      final rows = await SupabaseService.client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('title');
      return (rows as List<dynamic>)
          .map((r) => Habit.fromMap(
                r['id'] as String,
                Map<String, dynamic>.from(r as Map),
              ))
          .toList();
    }

    yield await fetch();
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 2));
      yield await fetch();
    }
  }
}
