import 'dart:math';

import 'package:mini_habit_rpg/models/personality_archetype.dart';

/// Motivational quotes shown on the home dashboard.
class MotivationalQuotes {
  MotivationalQuotes._();

  static final _random = Random();

  static const _general = [
    'Every quest begins with a single step.',
    'Small habits forge legendary heroes.',
    'Your future self is watching you win today.',
    'Consistency is the ultimate power-up.',
    'Level up your life, one habit at a time.',
  ];

  static const _scholar = [
    'Study the craft of discipline daily.',
    'Wisdom grows where focus is planted.',
  ];

  static const _warrior = [
    'Train your mind like a blade — sharp and steady.',
    'Victory belongs to those who never retreat.',
  ];

  static const _artist = [
    'Paint your days with intentional beauty.',
    'Creativity turns routine into ritual.',
  ];

  static String randomFor(PersonalityArchetype archetype) {
    final pool = [..._general, ..._forArchetype(archetype)];
    return pool[_random.nextInt(pool.length)];
  }

  static List<String> _forArchetype(PersonalityArchetype archetype) {
    switch (archetype) {
      case PersonalityArchetype.scholar:
        return _scholar;
      case PersonalityArchetype.warrior:
        return _warrior;
      case PersonalityArchetype.artist:
        return _artist;
    }
  }
}
