/// RPG personality paths — each path tweaks the app theme slightly.
enum PersonalityArchetype {
  scholar('Scholar', 'Knowledge is your greatest weapon.', '📚'),
  warrior('Warrior', 'Discipline forges unbreakable strength.', '⚔️'),
  artist('Artist', 'Creativity turns habits into masterpieces.', '🎨');

  const PersonalityArchetype(this.label, this.tagline, this.emoji);

  final String label;
  final String tagline;
  final String emoji;

  static PersonalityArchetype fromString(String? value) {
    return PersonalityArchetype.values.firstWhere(
      (a) => a.name == value,
      orElse: () => PersonalityArchetype.warrior,
    );
  }
}
