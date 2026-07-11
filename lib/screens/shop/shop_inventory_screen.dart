import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/shop_item.dart';
import 'package:mini_habit_rpg/models/inventory_item.dart';
import 'package:mini_habit_rpg/providers/inventory_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

class ShopInventoryScreen extends StatefulWidget {
  const ShopInventoryScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<ShopInventoryScreen> createState() => _ShopInventoryScreenState();
}

class _ShopInventoryScreenState extends State<ShopInventoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'rare':
        return Colors.blueAccent;
      case 'epic':
        return Colors.purpleAccent;
      case 'legendary':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handlePurchase(
      BuildContext context,
      UserProvider userProvider,
      InventoryProvider inventoryProvider,
      ShopItem item) async {
    final coins = userProvider.profile?.coins ?? 0;
    if (coins < item.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins! Earn more by completing habits.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Purchase ${item.name}?'),
        content: Text('This will cost you ${item.cost} coins. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Buy'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success = await inventoryProvider.purchaseItem(userProvider, item);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully purchased ${item.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase failed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleEquip(
      BuildContext context,
      UserProvider userProvider,
      InventoryProvider inventoryProvider,
      UserInventoryItem item) async {
    final success = await inventoryProvider.equipItem(
        userProvider, item.itemId, item.itemType);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.metadata?.name ?? "Item"} equipped!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _handleUseConsumable(
      BuildContext context,
      UserProvider userProvider,
      InventoryProvider inventoryProvider,
      UserInventoryItem item) async {
    final success =
        await inventoryProvider.useConsumable(userProvider, item.itemId);
    if (!context.mounted) return;

    if (success) {
      String msg = 'Item used!';
      if (item.itemId == 'consumable_xp_boost') {
        msg = 'Wisdom Elixir consumed! +100 XP gained!';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.teal),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final profile = userProvider.profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final coins = profile.coins;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get active theme to set scaffold bg
    final equippedThemeItem =
        inventoryProvider.getEquipped(ShopItemType.theme);
    final activeThemeId = equippedThemeItem?.itemId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realm Shop'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: const Icon(Icons.monetization_on, color: Colors.amber),
              label: Text(
                '$coins',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Shop', icon: Icon(Icons.store)),
            Tab(text: 'Inventory', icon: Icon(Icons.inventory_2)),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: AppTheme.environmentBackground(
          equippedThemeId: activeThemeId,
          archetype: profile.archetype,
          isDark: isDark,
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            // SHOP TAB VIEW
            _buildShopTab(userProvider, inventoryProvider),
            // INVENTORY TAB VIEW
            _buildInventoryTab(userProvider, inventoryProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildShopTab(
      UserProvider userProvider, InventoryProvider inventoryProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: ShopItem.catalog.length,
      itemBuilder: (context, index) {
        final item = ShopItem.catalog[index];
        final isOwned = inventoryProvider.isOwned(item.id);
        final qtyOwned = inventoryProvider.getConsumableCount(item.id);
        final isConsumable = item.type == ShopItemType.consumable;
        final rarityColor = _getRarityColor(item.rarity);

        return RpgCard(
          accentColor: rarityColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon & Rarity Badge
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.icon, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: rarityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: rarityColor, width: 0.5),
                      ),
                      child: Text(
                        item.rarity,
                        style: TextStyle(
                            fontSize: 10,
                            color: rarityColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Title and Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  item.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),

              // Price Chip / Quantity Tracker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isConsumable && qtyOwned > 0) ...[
                    Text('Owned: $qtyOwned',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.greenAccent)),
                    const SizedBox(width: 8),
                  ],
                  Chip(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.monetization_on,
                        color: Colors.amber, size: 14),
                    label: Text(
                      '${item.cost}',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Purchase button
              ElevatedButton(
                onPressed: (isOwned && !isConsumable)
                    ? null
                    : () => _handlePurchase(context, userProvider,
                        inventoryProvider, item),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  visualDensity: VisualDensity.compact,
                  backgroundColor:
                      isOwned && !isConsumable ? Colors.grey : null,
                ),
                child: Text(
                  isOwned && !isConsumable
                      ? 'Owned'
                      : isConsumable
                          ? 'Buy'
                          : 'Purchase',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryTab(
      UserProvider userProvider, InventoryProvider inventoryProvider) {
    final list = inventoryProvider.items;
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎒', style: TextStyle(fontSize: 64)),
            SizedBox(height: 12),
            Text(
              'Your inventory is empty.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Visit the Shop to buy equipment or items!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final meta = item.metadata;
        if (meta == null) return const SizedBox.shrink();

        final isEquipped = item.equipped;
        final isConsumable = item.itemType == ShopItemType.consumable;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(meta.icon, style: const TextStyle(fontSize: 32)),
            title: Row(
              children: [
                Text(meta.name),
                const SizedBox(width: 8),
                if (!isConsumable && isEquipped)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green, width: 0.5),
                    ),
                    child: const Text(
                      'Equipped',
                      style: TextStyle(fontSize: 8, color: Colors.green),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              isConsumable
                  ? '${meta.description} (Quantity: ${item.quantity})'
                  : meta.description,
              style: const TextStyle(fontSize: 11),
            ),
            trailing: isConsumable
                ? ElevatedButton(
                    onPressed: item.itemId == 'consumable_streak_shield'
                        ? null // Passive consumable
                        : () => _handleUseConsumable(
                            context, userProvider, inventoryProvider, item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.itemId == 'consumable_streak_shield'
                          ? Colors.grey
                          : null,
                    ),
                    child: Text(item.itemId == 'consumable_streak_shield'
                        ? 'Passive'
                        : 'Use'),
                  )
                : ElevatedButton(
                    onPressed: isEquipped
                        ? null
                        : () => _handleEquip(
                            context, userProvider, inventoryProvider, item),
                    child: Text(isEquipped ? 'Equipped' : 'Equip'),
                  ),
          ),
        );
      },
    );
  }
}
