/// A single habit quest stored in Firestore `habits` collection.
class Habit {
  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    required this.xpReward,
    this.completedAt,
  });

  final String id;
  final String userId;
  final String title;
  final bool completed;
  final int xpReward;
  final DateTime? completedAt;

  Habit copyWith({
    String? title,
    bool? completed,
    int? xpReward,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Habit(
      id: id,
      userId: userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      xpReward: xpReward ?? this.xpReward,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'completed': completed,
      'xpReward': xpReward,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    final completedAtRaw = map['completedAt'] as String?;
    return Habit(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      completed: map['completed'] as bool? ?? false,
      xpReward: map['xpReward'] as int? ?? 25,
      completedAt:
          completedAtRaw != null ? DateTime.tryParse(completedAtRaw) : null,
    );
  }
}
