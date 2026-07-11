import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/screens/settings/settings_screen.dart';
import 'package:mini_habit_rpg/screens/shop/shop_inventory_screen.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/utils/constants.dart';
import 'package:mini_habit_rpg/widgets/archetype_badge.dart';
import 'package:mini_habit_rpg/widgets/coin_badge.dart';
import 'package:mini_habit_rpg/widgets/personality_chart.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';
import 'package:mini_habit_rpg/widgets/xp_progress_bar.dart';

/// Account profile — settings and shop routes.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final avatarEmoji =
        AppConstants.avatarEmojis[profile.avatarId.clamp(
          0,
          AppConstants.avatarEmojis.length - 1,
        )];

    return Container(
      decoration: AppTheme.gradientBackground(profile.archetype),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              Center(
                child: Text(avatarEmoji, style: const TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 12),
              Text(
                profile.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                profile.personalityTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Center(child: ArchetypeBadge(archetype: profile.archetype)),
              const SizedBox(height: 8),
              Center(child: CoinBadge(coins: profile.coins)),
              const SizedBox(height: 24),
              RpgCard(
                child: XpProgressBar(
                  currentXp: profile.xp,
                  maxXp: profile.xpToNextLevel,
                  level: profile.level,
                ),
              ),
              const SizedBox(height: 16),
              PersonalityChart(profile: profile),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShopInventoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Visit Realm Shop'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
