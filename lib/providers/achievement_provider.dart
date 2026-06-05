import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/services/achievement_service.dart';

/// Tracks unlocked achievements.
class AchievementProvider extends ChangeNotifier {
  AchievementProvider({AchievementService? achievementService})
      : _achievementService = achievementService ?? AchievementService();

  final AchievementService _achievementService;

  List<UserAchievement> _achievements = [];
  StreamSubscription<List<UserAchievement>>? _subscription;
  String? _userId;

  List<UserAchievement> get achievements => List.unmodifiable(_achievements);
  List<UserAchievement> get unlocked =>
      _achievements.where((a) => a.unlocked).toList();

  Future<void> listenToAchievements(String userId) async {
    if (_userId == userId && _subscription != null) return;
    _userId = userId;
    await _subscription?.cancel();

    _subscription =
        _achievementService.watchAchievements(userId).listen((list) {
      _achievements = list;
      _scheduleNotify();
    });
  }

  void _scheduleNotify() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  void reset() {
    _subscription?.cancel();
    _achievements = [];
    _userId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
