import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/models/mood_entry.dart';
import 'package:mini_habit_rpg/services/mood_service.dart';

/// Tracks current mood and mood history.
class MoodProvider extends ChangeNotifier {
  MoodProvider({MoodService? moodService})
      : _moodService = moodService ?? MoodService();

  final MoodService _moodService;

  Mood? _currentMood;
  List<MoodEntry> _history = [];
  StreamSubscription<List<MoodEntry>>? _subscription;
  String? _userId;

  Mood? get currentMood => _currentMood;
  List<MoodEntry> get history => List.unmodifiable(_history);

  Future<void> listenToMood(String userId) async {
    if (_userId == userId && _subscription != null) return;
    _userId = userId;
    await _subscription?.cancel();

    _currentMood = _moodService.currentMood(userId);
    notifyListeners();

    _subscription = _moodService.watchHistory(userId).listen((entries) {
      _history = entries;
      if (entries.isNotEmpty && _currentMood == null) {
        _currentMood = entries.first.mood;
      }
      _scheduleNotify();
    });
  }

  Future<void> selectMood(Mood mood) async {
    if (_userId == null) return;
    _currentMood = mood;
    notifyListeners();
    await _moodService.recordMood(userId: _userId!, mood: mood);
  }

  void _scheduleNotify() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  void reset() {
    _subscription?.cancel();
    _currentMood = null;
    _history = [];
    _userId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
