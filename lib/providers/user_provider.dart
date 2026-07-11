import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/providers/inventory_provider.dart';
import 'package:mini_habit_rpg/services/achievement_service.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';
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
    required InventoryProvider inventoryProvider,
  }) async {
    final current = _profile;
    if (current == null) {
      return const RewardResult(leveledUp: false, newAchievements: []);
    }

    final today = XpCalculator.todayKey();
    final last = current.lastActiveDate;
    var updated = current;
    var shieldUsed = false;

    if (last != today) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      if (last != yesterdayKey && last != null) {
        // Missed a day! Check if they have a Streak Shield.
        final shieldCount =
            inventoryProvider.getConsumableCount('consumable_streak_shield');
        if (shieldCount > 0) {
          // Consume the shield
          await inventoryProvider.consumeStreakShield();
          shieldUsed = true;
          // Keep streak intact (increment as if we completed it yesterday)
          updated = current.copyWith(
            streak: current.streak + 1,
            lastActiveDate: today,
          );
        } else {
          // No shield, reset streak
          updated = current.copyWith(
            streak: 1,
            lastActiveDate: today,
          );
        }
      } else {
        // Normal streak increment (last is yesterday) or first time (last is null)
        final newStreak = last == yesterdayKey ? current.streak + 1 : 1;
        updated = current.copyWith(
          streak: newStreak,
          lastActiveDate: today,
        );
      }
    }

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

    // Check archetype achievements
    final Set<String> newAchievementsSet = {};
    if (updated.archetype == PersonalityArchetype.scholar) {
      newAchievementsSet.add(AchievementType.scholarArchetype.id);
    } else if (updated.archetype == PersonalityArchetype.warrior) {
      newAchievementsSet.add(AchievementType.warriorArchetype.id);
    } else if (updated.archetype == PersonalityArchetype.artist) {
      newAchievementsSet.add(AchievementType.artistArchetype.id);
    }

    if (shieldUsed) {
      newAchievementsSet.add(AchievementType.streakSaved.id);
    }

    await _userService.saveProfile(updated);
    _profile = updated;
    notifyListeners();

    final newAchievements = await _achievementService.checkAndUnlock(
      userId: current.uid,
      profile: updated,
    );

    // Apply awards from newly unlocked achievements
    if (newAchievements.isNotEmpty || newAchievementsSet.isNotEmpty) {
      var withRewards = updated;
      final allAchievementsToReward = [...newAchievements];

      // Add our custom triggers if not already unlocked
      final existingUnlocked = (await _achievementService.watchAchievements(current.uid).first)
          .where((a) => a.unlocked)
          .map((a) => a.achievementName)
          .toSet();

      for (final achId in newAchievementsSet) {
        if (!existingUnlocked.contains(achId)) {
          final achType = AchievementType.fromId(achId);
          if (achType != null) {
            allAchievementsToReward.add(achType);
            await _achievementService.checkAndUnlock(
              userId: current.uid,
              profile: updated,
            );
          }
        }
      }

      for (final type in allAchievementsToReward) {
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
      streakShieldUsed: shieldUsed,
    );
  }

  Future<void> applyCoinsDeduction(int cost) async {
    final current = _profile;
    if (current == null) return;
    final updated = current.copyWith(coins: (current.coins - cost).clamp(0, 99999));
    await _userService.saveProfile(updated);
    _profile = updated;
    notifyListeners();
  }

  Future<void> applyXpBonus(int xpAmount) async {
    final current = _profile;
    if (current == null) return;

    var updated = current.copyWith(
      totalXpEarned: current.totalXpEarned + xpAmount,
    );
    final result = XpCalculator.applyXp(updated, xpAmount);
    updated = result.profile;

    await _userService.saveProfile(updated);
    _profile = updated;
    notifyListeners();

    // Check achievements
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
  }

  Future<void> applyLoginRewards({
    required int xpReward,
    required int coinReward,
  }) async {
    final current = _profile;
    if (current == null) return;

    var updated = current.copyWith(
      coins: current.coins + coinReward,
      totalXpEarned: current.totalXpEarned + xpReward,
    );

    if (xpReward > 0) {
      final result = XpCalculator.applyXp(updated, xpReward);
      updated = result.profile;
    }

    await _userService.saveProfile(updated);
    _profile = updated;
    notifyListeners();
  }

  Future<void> checkAchievement(AchievementType type) async {
    final current = _profile;
    if (current == null) return;

    final newUnlocked = await _achievementService.unlockDirect(
      userId: current.uid,
      type: type,
    );

    if (newUnlocked.isNotEmpty) {
      var withRewards = current;
      for (final t in newUnlocked) {
        withRewards = withRewards.copyWith(
          coins: withRewards.coins + t.coinReward,
          totalXpEarned: withRewards.totalXpEarned + t.xpReward,
        );
        final xpResult = XpCalculator.applyXp(withRewards, t.xpReward);
        withRewards = xpResult.profile;
      }
      await _userService.saveProfile(withRewards);
      _profile = withRewards;
      notifyListeners();
    }
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

  Future<void> resetProgress() async {
    final current = _profile;
    if (current == null) return;
    final uid = current.uid;

    if (SupabaseService.isReady) {
      final client = SupabaseService.client;
      await Future.wait([
        client.from('habits').delete().eq('user_id', uid),
        client.from('daily_quests').delete().eq('user_id', uid),
        client.from('achievements').delete().eq('user_id', uid),
        client.from('user_inventory').delete().eq('user_id', uid),
        client.from('user_login_rewards').delete().eq('user_id', uid),
        client.from('mood_history').delete().eq('user_id', uid),
        client.from('profiles').update(UserProfile.initial(uid).toMap()).eq('id', uid),
      ]);
    } else {
      await DemoDataStore.instance.clearAllUserData(uid);
    }

    _profile = UserProfile.initial(uid);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String username,
    required String displayName,
    required String personalityTitle,
    required int avatarId,
  }) async {
    final current = _profile;
    if (current == null) return;

    final updated = current.copyWith(
      username: username,
      displayName: displayName,
      personalityTitle: personalityTitle,
      avatarId: avatarId,
    );

    await _userService.saveProfile(updated);
    _profile = updated;
    notifyListeners();
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
    this.streakShieldUsed = false,
  });

  final bool leveledUp;
  final List<AchievementType> newAchievements;
  final bool streakShieldUsed;
}
