import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';

/// Personality trait percentages derived from category points.
class PersonalityBreakdown {
  const PersonalityBreakdown({
    required this.scholarPercent,
    required this.warriorPercent,
    required this.artistPercent,
  });

  final double scholarPercent;
  final double warriorPercent;
  final double artistPercent;
}

/// Awards personality points and computes adaptive trait percentages.
class PersonalityCalculator {
  PersonalityCalculator._();

  static const int pointsPerCompletion = 10;

  static UserProfile awardPoints(UserProfile profile, HabitCategory category) {
    switch (category.archetype.name) {
      case 'scholar':
        return profile.copyWith(
          scholarPoints: profile.scholarPoints + pointsPerCompletion,
        );
      case 'warrior':
        return profile.copyWith(
          warriorPoints: profile.warriorPoints + pointsPerCompletion,
        );
      case 'artist':
        return profile.copyWith(
          artistPoints: profile.artistPoints + pointsPerCompletion,
        );
      default:
        return profile;
    }
  }

  static PersonalityBreakdown breakdown(UserProfile profile) {
    final total = profile.scholarPoints +
        profile.warriorPoints +
        profile.artistPoints;

    if (total == 0) {
      return const PersonalityBreakdown(
        scholarPercent: 33.3,
        warriorPercent: 33.3,
        artistPercent: 33.4,
      );
    }

    return PersonalityBreakdown(
      scholarPercent: (profile.scholarPoints / total) * 100,
      warriorPercent: (profile.warriorPoints / total) * 100,
      artistPercent: (profile.artistPoints / total) * 100,
    );
  }
}
