import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/shop_item.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/providers/inventory_provider.dart';
import 'package:mini_habit_rpg/utils/constants.dart';
import 'package:mini_habit_rpg/widgets/archetype_badge.dart';
import 'package:mini_habit_rpg/widgets/coin_badge.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';
import 'package:mini_habit_rpg/widgets/xp_progress_bar.dart';

/// Hero card on the dashboard — avatar, name, level, XP, streak, coins, and gear.
class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key, required this.profile});

  final UserProfile profile;

  Widget _buildCosmeticBadge(BuildContext context, String label, String icon, String name) {
    return Tooltip(
      message: name,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarEmoji = AppConstants.avatarEmojis[
        profile.avatarId.clamp(0, AppConstants.avatarEmojis.length - 1)];

    final inventoryProvider = context.watch<InventoryProvider>();
    final equippedHair = inventoryProvider.getEquipped(ShopItemType.hairstyle);
    final equippedOutfit = inventoryProvider.getEquipped(ShopItemType.outfit);
    final equippedAcc = inventoryProvider.getEquipped(ShopItemType.accessory);

    return RpgCard(
      accentColor: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(avatarEmoji, style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.personalityTitle,
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    ArchetypeBadge(archetype: profile.archetype),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 28),
                  Text(
                    '${profile.streak}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Streak',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: CoinBadge(coins: profile.coins),
          ),

          // Equipped Equipment Badges
          if (equippedHair != null || equippedOutfit != null || equippedAcc != null) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (equippedHair != null)
                  _buildCosmeticBadge(
                    context,
                    'Hair',
                    equippedHair.metadata?.icon ?? '💇',
                    equippedHair.metadata?.name ?? '',
                  ),
                if (equippedOutfit != null)
                  _buildCosmeticBadge(
                    context,
                    'Armor',
                    equippedOutfit.metadata?.icon ?? '🛡️',
                    equippedOutfit.metadata?.name ?? '',
                  ),
                if (equippedAcc != null)
                  _buildCosmeticBadge(
                    context,
                    'Gear',
                    equippedAcc.metadata?.icon ?? '🪄',
                    equippedAcc.metadata?.name ?? '',
                  ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          XpProgressBar(
            currentXp: profile.xp,
            maxXp: profile.xpToNextLevel,
            level: profile.level,
          ),
        ],
      ),
    );
  }
}
