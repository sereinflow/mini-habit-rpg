import 'package:flutter_test/flutter_test.dart';
import 'package:mini_habit_rpg/utils/xp_calculator.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';

void main() {
  test('XP calculator levels up when threshold reached', () {
    final profile = UserProfile.initial('test').copyWith(level: 1, xp: 90);
    final result = XpCalculator.applyXp(profile, 25);

    expect(result.leveledUp, isTrue);
    expect(result.profile.level, 2);
    expect(result.profile.xp, 15);
  });

  test('Streak increments on new day', () {
    final profile = UserProfile.initial('test').copyWith(
      streak: 3,
      lastActiveDate: '2020-01-01',
    );
    final updated = XpCalculator.updateStreak(profile);
    expect(updated.streak, greaterThanOrEqualTo(1));
  });
}
