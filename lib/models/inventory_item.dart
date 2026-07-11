import 'package:mini_habit_rpg/models/shop_item.dart';

class UserInventoryItem {
  const UserInventoryItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.quantity,
    required this.equipped,
    required this.purchasedAt,
  });

  final String id;
  final String userId;
  final String itemId;
  final ShopItemType itemType;
  final int quantity;
  final bool equipped;
  final DateTime purchasedAt;

  ShopItem? get metadata => ShopItem.getById(itemId);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': itemId,
      'item_type': itemType.name,
      'quantity': quantity,
      'equipped': equipped,
      'purchased_at': purchasedAt.toIso8601String(),
    };
  }

  factory UserInventoryItem.fromMap(String id, Map<String, dynamic> map) {
    final purchasedAtRaw = map['purchased_at'] as String?;
    final typeStr = map['item_type'] as String? ?? 'consumable';
    final type = ShopItemType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => ShopItemType.consumable,
    );

    return UserInventoryItem(
      id: id,
      userId: map['user_id'] as String? ?? '',
      itemId: map['item_id'] as String? ?? '',
      itemType: type,
      quantity: map['quantity'] as int? ?? 1,
      equipped: map['equipped'] as bool? ?? false,
      purchasedAt:
          purchasedAtRaw != null ? DateTime.parse(purchasedAtRaw) : DateTime.now(),
    );
  }

  UserInventoryItem copyWith({
    int? quantity,
    bool? equipped,
  }) {
    return UserInventoryItem(
      id: id,
      userId: userId,
      itemId: itemId,
      itemType: itemType,
      quantity: quantity ?? this.quantity,
      equipped: equipped ?? this.equipped,
      purchasedAt: purchasedAt,
    );
  }
}
