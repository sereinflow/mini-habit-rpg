import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/utils/constants.dart';
import 'package:mini_habit_rpg/utils/personality_calculator.dart';
import 'package:mini_habit_rpg/widgets/archetype_badge.dart';
import 'package:mini_habit_rpg/widgets/coin_badge.dart';
import 'package:mini_habit_rpg/widgets/personality_chart.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';
import 'package:mini_habit_rpg/widgets/xp_progress_bar.dart';

/// RPG character profile — avatar, stats, and personality evolution.
class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

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
    final breakdown = PersonalityCalculator.breakdown(profile);

    return Container(
      decoration: AppTheme.gradientBackground(profile.archetype),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: const Text('Character'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _CharacterHeader(
                    profile: profile,
                    avatarEmoji: avatarEmoji,
                  ),
                  const SizedBox(height: 16),
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
                            _StatTile(
                              icon: Icons.star,
                              label: 'Level',
                              value: '${profile.level}',
                              color: Colors.amber,
                            ),
                            _StatTile(
                              icon: Icons.bolt,
                              label: 'XP',
                              value: '${profile.totalXpEarned}',
                              color: Colors.orange,
                            ),
                            _StatTile(
                              icon: Icons.local_fire_department,
                              label: 'Streak',
                              value: '${profile.streak}',
                              color: Colors.deepOrange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  RpgCard(
                    accentColor: AppTheme.accentFor(profile.archetype),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Class Stats',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 16),
                        _ClassStatRow(
                          label: 'Scholar',
                          emoji: '📚',
                          points: profile.scholarPoints,
                          percent: breakdown.scholarPercent,
                          color: const Color(0xFF5C7CFA),
                        ),
                        const SizedBox(height: 10),
                        _ClassStatRow(
                          label: 'Warrior',
                          emoji: '⚔️',
                          points: profile.warriorPoints,
                          percent: breakdown.warriorPercent,
                          color: const Color(0xFFE03131),
                        ),
                        const SizedBox(height: 10),
                        _ClassStatRow(
                          label: 'Artist',
                          emoji: '🎨',
                          points: profile.artistPoints,
                          percent: breakdown.artistPercent,
                          color: const Color(0xFFF59F00),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PersonalityChart(profile: profile),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterHeader extends StatelessWidget {
  const _CharacterHeader({
    required this.profile,
    required this.avatarEmoji,
  });

  final UserProfile profile;
  final String avatarEmoji;

  @override
  Widget build(BuildContext context) {
    return RpgCard(
      accentColor: AppTheme.accentFor(profile.archetype),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accentFor(profile.archetype),
                width: 3,
              ),
            ),
            child: Text(avatarEmoji, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 12),
          Text(
            profile.username,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ArchetypeBadge(archetype: profile.archetype),
          const SizedBox(height: 8),
          CoinBadge(coins: profile.coins),
          const SizedBox(height: 8),
          Text(
            profile.archetype.tagline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.white54,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ClassStatRow extends StatelessWidget {
  const _ClassStatRow({
    required this.label,
    required this.emoji,
    required this.points,
    required this.percent,
    required this.color,
  });

  final String label;
  final String emoji;
  final int points;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$emoji $label', style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(
          '$points pts',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 12),
        Text(
          '${percent.toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
