/// Player mood — affects which habits are recommended on the quest board.
enum Mood {
  motivated('Motivated', '🔥', 'High energy — tackle any quest'),
  tired('Tired', '😴', 'Light quests — easy wins only'),
  happy('Happy', '😊', 'Creative quests feel best today'),
  stressed('Stressed', '😰', 'Movement & discipline help most');

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
