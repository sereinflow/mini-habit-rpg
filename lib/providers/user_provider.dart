import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/services/achievement_service.dart';
import 'package:mini_habit_rpg/services/user_service.dart';
import 'package:mini_habit_rpg/utils/personality_calculator.dart';
import 'package:mini_habit_rpg/utils/xp_calculator.dart';

/// Loads and updates the user's RPG profile and rewards.
class UserProvider extends ChangeNotifier {
  UserProvider({
    UserService? userService,
    AchievementService? achievementService,
  })  : _userService = userService ?? UserService(),
        _achievementService = achievementService ?? AchievementService();

  final UserService _userService;
  final AchievementService _achievementService;

  UserProfile? _profile;
  bool _loading = false;
  String? _error;
  StreamSubscription<UserProfile?>? _subscription;

  UserProfile? get profile => _profile;
  bool get isLoading => _loading;
  String? get error => _error;

  bool get needsOnboarding {
    final p = _profile;
    if (p == null) return false;
    return p.username == 'Adventurer' || p.username.isEmpty;
  }

  Future<void> listenToUser(String uid) async {
    await _subscription?.cancel();
    _loading = true;
    notifyListeners();

    try {
      _profile = await _userService.getOrCreateProfile(uid);
      _loading = false;
      notifyListeners();

      _subscription = _userService.watchProfile(uid).listen((profile) {
        if (profile != null) {
          _profile = profile;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (hasListeners) notifyListeners();
          });
        }
      });
    } catch (e) {
      _error = 'Failed to load profile.';
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding({
    required String uid,
    required String username,
    required int avatarId,
    required PersonalityArchetype archetype,
  }) async {
    await _userService.completeOnboarding(
      uid: uid,
      username: username,
      avatarId: avatarId,
      archetype: archetype,
    );
    _profile = await _userService.getOrCreateProfile(uid);
    notifyListeners();
  }

  Future<RewardResult> applyHabitReward({
    required int xpReward,
    required int coinReward,
    required HabitCategory category,
  }) async {
    final current = _profile;
    if (current == null) {
      return const RewardResult(leveledUp: false, newAchievements: []);
    }

    var updated = XpCalculator.updateStreak(current);
    final longest = updated.streak > updated.longestStreak
        ? updated.streak
        : updated.longestStreak;
    updated = updated.copyWith(
      longestStreak: longest,
      totalHabitsCompleted: updated.totalHabitsCompleted + 1,
      totalXpEarned: updated.totalXpEarned + xpReward,
      coins: updated.coins + coinReward,
    );
    updated = PersonalityCalculator.awardPoints(updated, category);

    final result = XpCalculator.applyXp(updated, xpReward);
    updated = result.profile;

    await _userService.saveProfile(updated);
    _profile = updated;
    notifyListeners();

    final newAchievements = await _achievementService.checkAndUnlock(
      userId: current.uid,
      profile: updated,
    );

    if (newAchievements.isNotEmpty) {
      var withRewards = updated;
      for (final type in newAchievements) {
        withRewards = withRewards.copyWith(
          coins: withRewards.coins + type.coinReward,
          totalXpEarned: withRewards.totalXpEarned + type.xpReward,
        );
        final xpResult = XpCalculator.applyXp(withRewards, type.xpReward);
        withRewards = xpResult.profile;
      }
      await _userService.saveProfile(withRewards);
      _profile = withRewards;
      notifyListeners();
    }

    return RewardResult(
      leveledUp: result.leveledUp,
      newAchievements: newAchievements,
    );
  }

  Future<RewardResult> applyQuestReward({
    required int xpReward,
    required int coinReward,
  }) async {
    final current = _profile;
    if (current == null) {
      return const RewardResult(leveledUp: false, newAchievements: []);
    }

    var updated = current.copyWith(
      coins: current.coins + coinReward,
      totalXpEarned: current.totalXpEarned + xpReward,
    );
    final result = XpCalculator.applyXp(updated, xpReward);
    updated = result.profile;

    await _userService.saveProfile(updated);
    _profile = updated;
    notifyListeners();

    return RewardResult(
      leveledUp: result.leveledUp,
      newAchievements: const [],
    );
  }

  void reset() {
    _subscription?.cancel();
    _profile = null;
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

/// Result of applying XP/coin rewards.
class RewardResult {
  const RewardResult({
    required this.leveledUp,
    required this.newAchievements,
  });

  final bool leveledUp;
  final List<AchievementType> newAchievements;
}
