import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/providers/auth_provider.dart';
import 'package:mini_habit_rpg/providers/habit_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/utils/constants.dart';
import 'package:mini_habit_rpg/widgets/archetype_badge.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';
import 'package:mini_habit_rpg/widgets/xp_progress_bar.dart';

/// View profile stats and sign out.
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

    context.read<HabitProvider>().reset();
    context.read<UserProvider>().reset();
    await context.read<AuthProvider>().signOut();
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final avatarEmoji = AppConstants.avatarEmojis[
        profile.avatarId.clamp(0, AppConstants.avatarEmojis.length - 1)];

    return Scaffold(
      appBar: AppBar(title: const Text('Hero Profile')),
      body: Container(
        decoration: AppTheme.gradientBackground(profile.archetype),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Text(avatarEmoji, style: const TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 12),
            Text(
              profile.username,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Center(child: ArchetypeBadge(archetype: profile.archetype)),
            const SizedBox(height: 24),
            RpgCard(
              child: Column(
                children: [
                  XpProgressBar(
                    currentXp: profile.xp,
                    maxXp: profile.xpToNextLevel,
                    level: profile.level,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        icon: Icons.star,
                        label: 'Level',
                        value: '${profile.level}',
                      ),
                      _StatColumn(
                        icon: Icons.bolt,
                        label: 'Total XP',
                        value: '${profile.xp}',
                      ),
                      _StatColumn(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value: '${profile.streak}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            RpgCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.archetype.tagline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Path: ${profile.archetype.label}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
