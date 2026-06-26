import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/services/daily_quest_service.dart';

/// Manages daily quest list, mood-based regeneration, and completion.
class DailyQuestProvider extends ChangeNotifier {
  DailyQuestProvider({DailyQuestService? questService})
      : _questService = questService ?? DailyQuestService();

  final DailyQuestService _questService;

  List<DailyQuest> _quests = [];
  bool _loading = false;
  Mood? _activeMood;
  StreamSubscription<List<DailyQuest>>? _subscription;
  String? _userId;

  List<DailyQuest> get quests => List.unmodifiable(_quests);
  List<DailyQuest> get completedQuests =>
      _quests.where((q) => q.completed).toList();
  List<DailyQuest> get incompleteQuests =>
      _quests.where((q) => !q.completed).toList();
  bool get isLoading => _loading;
  Mood? get activeMood => _activeMood;

  /// Regenerates quests when the player picks a new mood.
  Future<void> regenerateForMood(Mood mood) async {
    if (_userId == null) return;
    _activeMood = mood;
    _loading = true;
    notifyListeners();

    _quests = await _questService.regenerateForMood(_userId!, mood);

    _loading = false;
    notifyListeners();
  }

  Future<void> listenToQuests(String userId, {Mood? mood}) async {
    final effectiveMood = mood ?? _activeMood ?? Mood.motivated;

    if (_userId != userId || _subscription == null) {
      _userId = userId;
      _activeMood = effectiveMood;
      await _subscription?.cancel();
      _loading = true;
      notifyListeners();

      _quests =
          await _questService.ensureTodayQuests(userId, mood: effectiveMood);

      _subscription = _questService.watchQuests(userId).listen((quests) {
        if (quests.isNotEmpty) _quests = quests;
        _loading = false;
        _scheduleNotify();
      });

      _loading = false;
      notifyListeners();
    } else if (effectiveMood != _activeMood) {
      await regenerateForMood(effectiveMood);
    }
  }

  Future<DailyQuest?> completeQuest(DailyQuest quest) async {
    if (quest.completed) return null;
    final completed = quest.copyWith(completed: true);
    await _questService.updateQuest(completed);
    final index = _quests.indexWhere((q) => q.id == quest.id);
    if (index >= 0) {
      _quests[index] = completed;
      notifyListeners();
    }
    return completed;
  }

  void _scheduleNotify() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  void reset() {
    _subscription?.cancel();
    _quests = [];
    _userId = null;
    _activeMood = null;
    _loading = false;
    _subscription = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
