import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/utils/constants.dart';
import 'package:mini_habit_rpg/widgets/archetype_badge.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';
import 'package:mini_habit_rpg/widgets/xp_progress_bar.dart';

/// Hero card on the dashboard — avatar, name, level, XP, streak.
class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final avatarEmoji = AppConstants.avatarEmojis[
        profile.avatarId.clamp(0, AppConstants.avatarEmojis.length - 1)];

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
                      profile.username,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
          const SizedBox(height: 20),
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
