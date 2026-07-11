import 'package:flutter/foundation.dart';
import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/login_reward.dart';
import 'package:mini_habit_rpg/models/shop_item.dart';
import 'package:mini_habit_rpg/providers/inventory_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/repositories/login_reward_repository.dart';
import 'package:mini_habit_rpg/utils/xp_calculator.dart';

class LoginRewardProvider extends ChangeNotifier {
  LoginRewardProvider({LoginRewardRepository? repository})
      : _repository = repository ?? LoginRewardRepository();

  final LoginRewardRepository _repository;
  String? _userId;
  String? _lastClaimedDate;
  int _consecutiveDays = 0;
  bool _isLoading = false;

  String? get lastClaimedDate => _lastClaimedDate;
  int get consecutiveDays => _consecutiveDays;
  bool get isLoading => _isLoading;

  Future<void> loadRewardState(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    try {
      final state = await _repository.getRewardState(userId);
      if (state != null) {
        _lastClaimedDate = state['last_claimed_date'] as String?;
        _consecutiveDays = state['consecutive_days'] as int? ?? 0;
      } else {
        _lastClaimedDate = null;
        _consecutiveDays = 0;
      }
    } catch (e) {
      debugPrint('Error loading login reward state: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get canClaimReward {
    if (_userId == null) return false;
    final today = XpCalculator.todayKey();
    if (_lastClaimedDate == today) {
      return false; // Already claimed today
    }
    return true; // Not claimed today
  }

  int get nextRewardDay {
    if (_lastClaimedDate == null) {
      return 1;
    }

    final today = XpCalculator.todayKey();
    if (_lastClaimedDate == today) {
      return _consecutiveDays; // Already claimed today, show current
    }

    // Check if yesterday
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    if (_lastClaimedDate == yesterdayKey) {
      final nextDay = _consecutiveDays + 1;
      return nextDay > 7 ? 1 : nextDay; // Wrap around to 1 after day 7
    }

    // Missed a day, reset to 1
    return 1;
  }

  Future<LoginReward?> claimDailyReward({
    required UserProvider userProvider,
    required InventoryProvider inventoryProvider,
  }) async {
    if (_userId == null || !canClaimReward) return null;

    final targetDay = nextRewardDay;
    final reward = LoginReward.getByDay(targetDay);
    final today = XpCalculator.todayKey();

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Save reward state in DB
      await _repository.saveRewardState(
        userId: _userId!,
        lastClaimedDate: today,
        consecutiveDays: targetDay,
      );

      _lastClaimedDate = today;
      _consecutiveDays = targetDay;

      // 2. Apply Rewards to User
      if (reward.coinReward > 0 || reward.xpReward > 0) {
        await userProvider.applyLoginRewards(
          xpReward: reward.xpReward,
          coinReward: reward.coinReward,
        );
      }

      // 3. Apply Cosmetic/Consumable Item if exists
      if (reward.itemIdReward != null) {
        final item = ShopItem.getById(reward.itemIdReward!);
        if (item != null) {
          // Grant item to inventory for free
          await inventoryProvider.grantItemFree(item);
        }
      }

      // Check "Realm Traveler" achievement (claimed day 7 reward)
      if (targetDay == 7) {
        await userProvider.checkAchievement(AchievementType.luckyLogin);
      }

      _isLoading = false;
      notifyListeners();
      return reward;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error claiming daily login reward: $e');
      return null;
    }
  }

  void reset() {
    _userId = null;
    _lastClaimedDate = null;
    _consecutiveDays = 0;
    _isLoading = false;
    notifyListeners();
  }
}
