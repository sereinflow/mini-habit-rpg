/// Player mood — affects theme, recommendations, and quest filtering.
enum Mood {
  motivated('Motivated', '🔥', 'High energy — tackle any quest'),
  tired('Tired', '😴', 'Light quests — easy wins only'),
  stressed('Stressed', '😰', 'Wellness habits help most'),
  happy('Happy', '😊', 'Bonus quests feel best today');

  const Mood(this.label, this.emoji, this.hint);

  final String label;
  final String emoji;
  final String hint;

  static Mood fromString(String? value) {
    return Mood.values.firstWhere(
      (m) => m.name == value,
      orElse: () => Mood.motivated,
    );
  }
}
