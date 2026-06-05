import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/services/daily_quest_service.dart';

/// Manages daily quest list and completion.
class DailyQuestProvider extends ChangeNotifier {
  DailyQuestProvider({DailyQuestService? questService})
      : _questService = questService ?? DailyQuestService();

  final DailyQuestService _questService;

  List<DailyQuest> _quests = [];
  bool _loading = false;
  StreamSubscription<List<DailyQuest>>? _subscription;
  String? _userId;

  List<DailyQuest> get quests => List.unmodifiable(_quests);
  List<DailyQuest> get completedQuests =>
      _quests.where((q) => q.completed).toList();
  List<DailyQuest> get incompleteQuests =>
      _quests.where((q) => !q.completed).toList();
  bool get isLoading => _loading;

  Future<void> listenToQuests(String userId) async {
    if (_userId == userId && _subscription != null) return;
    _userId = userId;
    await _subscription?.cancel();
    _loading = true;
    notifyListeners();

    await _questService.ensureTodayQuests(userId);

    _subscription = _questService.watchQuests(userId).listen((quests) {
      _quests = quests;
      _loading = false;
      _scheduleNotify();
    });
  }

  Future<DailyQuest?> completeQuest(DailyQuest quest) async {
    if (quest.completed) return null;
    final completed = quest.copyWith(completed: true);
    await _questService.updateQuest(completed);
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
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
