import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/services/habit_service.dart';

/// Manages habit list CRUD and completion toggles.
class HabitProvider extends ChangeNotifier {
  HabitProvider({HabitService? habitService})
      : _habitService = habitService ?? HabitService();

  final HabitService _habitService;

  List<Habit> _habits = [];
  bool _loading = false;
  String? _error;
  StreamSubscription<List<Habit>>? _subscription;
  String? _userId;

  List<Habit> get habits => List.unmodifiable(_habits);
  List<Habit> get todayIncomplete =>
      _habits.where((h) => !h.completed).toList();
  List<Habit> get todayCompleted =>
      _habits.where((h) => h.completed).toList();
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> listenToHabits(String userId) async {
    if (_userId == userId && _subscription != null) return;
    _userId = userId;
    await _subscription?.cancel();
    _loading = true;
    notifyListeners();

    _subscription = _habitService.watchHabits(userId).listen(
      (habits) {
        _habits = habits;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Failed to load habits.';
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addHabit(String title) async {
    if (_userId == null || title.trim().isEmpty) return;
    await _habitService.addHabit(userId: _userId!, title: title);
  }

  Future<Habit?> toggleComplete(Habit habit) async {
    if (habit.completed) {
      final reset = habit.copyWith(
        completed: false,
        clearCompletedAt: true,
      );
      await _habitService.updateHabit(reset);
      return null;
    }

    final completed = habit.copyWith(
      completed: true,
      completedAt: DateTime.now(),
    );
    await _habitService.updateHabit(completed);
    return completed;
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitService.deleteHabit(habitId);
  }

  void reset() {
    _subscription?.cancel();
    _habits = [];
    _userId = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
