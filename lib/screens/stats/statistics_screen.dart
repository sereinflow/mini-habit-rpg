import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/providers/achievement_provider.dart';
import 'package:mini_habit_rpg/providers/habit_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/widgets/achievement_tile.dart';
import 'package:mini_habit_rpg/widgets/personality_chart.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Professional statistics dashboard.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;
    final habitProvider = context.watch<HabitProvider>();
    final achievementProvider = context.watch<AchievementProvider>();

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final unlockedIds = achievementProvider.unlocked
        .map((a) => a.achievementName)
        .toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Container(
        decoration: AppTheme.gradientBackground(profile.archetype),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Your Journey',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Habits Completed',
                  value: '${profile.totalHabitsCompleted}',
                  color: Colors.greenAccent,
                ),
                _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Current Streak',
                  value: '${profile.streak} days',
                  color: Colors.orange,
                ),
                _StatCard(
                  icon: Icons.whatshot,
                  label: 'Longest Streak',
                  value: '${profile.longestStreak} days',
                  color: Colors.deepOrange,
                ),
                _StatCard(
                  icon: Icons.star,
                  label: 'Total XP Earned',
                  value: '${profile.totalXpEarned}',
                  color: Colors.amber,
                ),
                _StatCard(
                  icon: Icons.monetization_on,
                  label: 'Coins',
                  value: '${profile.coins}',
                  color: Colors.yellow,
                ),
                _StatCard(
                  icon: Icons.pie_chart,
                  label: 'Today\'s Completion',
                  value:
                      '${habitProvider.completionPercentage.toStringAsFixed(0)}%',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            PersonalityChart(profile: profile),
            const SizedBox(height: 24),
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...AchievementType.values.map(
              (type) => AchievementTile(
                type: type,
                unlocked: unlockedIds.contains(type.id),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RpgCard(
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ],
      ),
    );
  }
}
