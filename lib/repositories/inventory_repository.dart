import 'dart:async';
import 'package:mini_habit_rpg/models/inventory_item.dart';
import 'package:mini_habit_rpg/models/shop_item.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryRepository {
  InventoryRepository({DemoDataStore? store})
      : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;

  Future<List<UserInventoryItem>> getInventory(String userId) async {
    if (SupabaseService.isReady) {
      final client = SupabaseService.client;
      final response = await client
          .from('user_inventory')
          .select()
          .eq('user_id', userId);
      return (response as List<dynamic>)
          .map((row) => UserInventoryItem.fromMap(row['id'] as String, Map<String, dynamic>.from(row)))
          .toList();
    }
    await _store.ensureLoaded();
    return _store.inventoryFor(userId);
  }

  Stream<List<UserInventoryItem>> watch(String userId) {
    if (SupabaseService.isReady) {
      return _watchSupabase(userId);
    }
    final controller = _store.inventoryController(userId);
    Future.microtask(() => controller.add(_store.inventoryFor(userId)));
    return controller.stream;
  }

  Future<void> purchase(String userId, ShopItem item) async {
    if (SupabaseService.isReady) {
      final client = SupabaseService.client;
      final existing = await client
          .from('user_inventory')
          .select()
          .eq('user_id', userId)
          .eq('item_id', item.id)
          .maybeSingle();

      if (existing != null) {
        if (item.type == ShopItemType.consumable) {
          final currentQty = existing['quantity'] as int? ?? 1;
          await client
              .from('user_inventory')
              .update({'quantity': currentQty + 1})
              .eq('user_id', userId)
              .eq('item_id', item.id);
        }
      } else {
        await client.from('user_inventory').insert({
          'user_id': userId,
          'item_id': item.id,
          'item_type': item.type.name,
          'quantity': 1,
          'equipped': false,
        });
      }
      return;
    }

    await _store.ensureLoaded();
    final list = _store.inventoryByUser.putIfAbsent(userId, () => []);
    final idx = list.indexWhere((i) => i.itemId == item.id);
    if (idx != -1) {
      if (item.type == ShopItemType.consumable) {
        list[idx] = list[idx].copyWith(quantity: list[idx].quantity + 1);
      }
    } else {
      list.add(UserInventoryItem(
        id: 'inv_${item.id}_${DateTime.now().microsecondsSinceEpoch}',
        userId: userId,
        itemId: item.id,
        itemType: item.type,
        quantity: 1,
        equipped: false,
        purchasedAt: DateTime.now(),
      ));
    }
    await _store.emitInventory(userId);
  }

  Future<void> equip(String userId, String itemId, ShopItemType type) async {
    if (SupabaseService.isReady) {
      final client = SupabaseService.client;
      // Unequip all items of this type
      await client
          .from('user_inventory')
          .update({'equipped': false})
          .eq('user_id', userId)
          .eq('item_type', type.name);
      // Equip target item
      await client
          .from('user_inventory')
          .update({'equipped': true})
          .eq('user_id', userId)
          .eq('item_id', itemId);
      return;
    }

    await _store.ensureLoaded();
    final list = _store.inventoryByUser[userId] ?? [];
    for (var i = 0; i < list.length; i++) {
      if (list[i].itemType == type) {
        list[i] = list[i].copyWith(equipped: list[i].itemId == itemId);
      }
    }
    await _store.emitInventory(userId);
  }

  Future<void> consume(String userId, String itemId) async {
    if (SupabaseService.isReady) {
      final client = SupabaseService.client;
      final existing = await client
          .from('user_inventory')
          .select()
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .maybeSingle();

      if (existing != null) {
        final currentQty = existing['quantity'] as int? ?? 1;
        if (currentQty <= 1) {
          await client
              .from('user_inventory')
              .delete()
              .eq('user_id', userId)
              .eq('item_id', itemId);
        } else {
          await client
              .from('user_inventory')
              .update({'quantity': currentQty - 1})
              .eq('user_id', userId)
              .eq('item_id', itemId);
        }
      }
      return;
    }

    await _store.ensureLoaded();
    final list = _store.inventoryByUser[userId] ?? [];
    final idx = list.indexWhere((i) => i.itemId == itemId);
    if (idx != -1) {
      if (list[idx].quantity <= 1) {
        list.removeAt(idx);
      } else {
        list[idx] = list[idx].copyWith(quantity: list[idx].quantity - 1);
      }
      await _store.emitInventory(userId);
    }
  }

  Stream<List<UserInventoryItem>> _watchSupabase(String userId) async* {
    yield await getInventory(userId);

    final channel = SupabaseService.client
        .channel('inventory_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_inventory',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) {},
        )
        .subscribe();

    try {
      while (true) {
        await Future<void>.delayed(const Duration(seconds: 2));
        yield await getInventory(userId);
      }
    } finally {
      await SupabaseService.client.removeChannel(channel);
    }
  }
}
