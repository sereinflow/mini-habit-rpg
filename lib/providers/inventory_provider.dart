import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/inventory_item.dart';
import 'package:mini_habit_rpg/models/shop_item.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  InventoryProvider({InventoryRepository? repository})
      : _repository = repository ?? InventoryRepository();

  final InventoryRepository _repository;
  List<UserInventoryItem> _items = [];
  StreamSubscription<List<UserInventoryItem>>? _subscription;
  String? _userId;
  bool _isLoading = false;

  List<UserInventoryItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  List<UserInventoryItem> get cosmetics =>
      _items.where((i) => i.itemType != ShopItemType.consumable && i.itemType != ShopItemType.theme).toList();

  List<UserInventoryItem> get themes =>
      _items.where((i) => i.itemType == ShopItemType.theme).toList();

  List<UserInventoryItem> get consumables =>
      _items.where((i) => i.itemType == ShopItemType.consumable).toList();

  UserInventoryItem? getEquipped(ShopItemType type) {
    for (final item in _items) {
      if (item.itemType == type && item.equipped) {
        return item;
      }
    }
    return null;
  }

  int getConsumableCount(String itemId) {
    for (final item in _items) {
      if (item.itemId == itemId) {
        return item.quantity;
      }
    }
    return 0;
  }

  bool isOwned(String itemId) {
    return _items.any((i) => i.itemId == itemId);
  }

  Future<void> listenToInventory(String userId) async {
    if (_userId == userId && _subscription != null) return;
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    await _subscription?.cancel();
    _subscription = _repository.watch(userId).listen((list) {
      _items = list;
      _isLoading = false;
      _scheduleNotify();
    });
  }

  Future<bool> purchaseItem(UserProvider userProvider, ShopItem item) async {
    final profile = userProvider.profile;
    if (profile == null || _userId == null) return false;

    if (profile.coins < item.cost) {
      return false; // Not enough coins
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Deduct coins
      await userProvider.applyCoinsDeduction(item.cost);
      // Save purchase in inventory
      await _repository.purchase(_userId!, item);

      // Check "First Purchase" achievement
      await userProvider.checkAchievement(AchievementType.buyShopItem);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> grantItemFree(ShopItem item) async {
    if (_userId == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.purchase(_userId!, item);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> equipItem(UserProvider userProvider, String itemId, ShopItemType type) async {
    if (_userId == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.equip(_userId!, itemId, type);

      // Check "Style Icon" achievement
      if (type == ShopItemType.outfit || type == ShopItemType.hairstyle || type == ShopItemType.accessory) {
        await userProvider.checkAchievement(AchievementType.equipCosmetic);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> useConsumable(UserProvider userProvider, String itemId) async {
    if (_userId == null) return false;
    final count = getConsumableCount(itemId);
    if (count <= 0) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.consume(_userId!, itemId);

      // Apply effect
      if (itemId == 'consumable_xp_boost') {
        // Wisdom Elixir grants +100 XP
        await userProvider.applyXpBonus(100);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> consumeStreakShield() async {
    if (_userId == null) return false;
    const shieldId = 'consumable_streak_shield';
    final count = getConsumableCount(shieldId);
    if (count <= 0) return false;

    try {
      await _repository.consume(_userId!, shieldId);
      return true;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _items = [];
    _userId = null;
    _isLoading = false;
    notifyListeners();
  }

  void _scheduleNotify() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
