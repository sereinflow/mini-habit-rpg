import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/providers/auth_provider.dart';
import 'package:mini_habit_rpg/providers/daily_quest_provider.dart';
import 'package:mini_habit_rpg/providers/habit_provider.dart';
import 'package:mini_habit_rpg/providers/mood_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/utils/constants.dart';
import 'package:mini_habit_rpg/widgets/archetype_badge.dart';
import 'package:mini_habit_rpg/widgets/coin_badge.dart';
import 'package:mini_habit_rpg/widgets/personality_chart.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';
import 'package:mini_habit_rpg/widgets/xp_progress_bar.dart';
import 'package:mini_habit_rpg/providers/achievement_provider.dart';

/// Account profile — settings and sign out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave the Realm?'),
        content: const Text('You will be signed out of your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    context.read<AchievementProvider>().reset();
    context.read<DailyQuestProvider>().reset();
    context.read<MoodProvider>().reset();
    context.read<HabitProvider>().reset();
    context.read<UserProvider>().reset();
    await context.read<AuthProvider>().signOut();
  }

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
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Account', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Center(
              child: Text(avatarEmoji, style: const TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 12),
            Text(
              profile.username,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
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
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
