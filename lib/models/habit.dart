import 'package:mini_habit_rpg/models/habit_category.dart';

/// A single habit quest stored in Supabase `habits` or local demo store.
class Habit {
  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.completed,
    required this.xpReward,
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final String userId;
  final String title;
  final HabitCategory category;
  final bool completed;
  final int xpReward;
  final DateTime? createdAt;
  final DateTime? completedAt;

  int get coinReward => (xpReward / 5).round().clamp(1, 50);

  Habit copyWith({
    String? title,
    HabitCategory? category,
    bool? completed,
    int? xpReward,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Habit(
      id: id,
      userId: userId,
      title: title ?? this.title,
      category: category ?? this.category,
      completed: completed ?? this.completed,
      xpReward: xpReward ?? this.xpReward,
      createdAt: createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'category': category.name,
      'xp_reward': xpReward,
      'completed': completed,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    final createdAtRaw = map['created_at'] as String?;
    final completedAtRaw = map['completed_at'] as String?;
    return Habit(
      id: id,
      userId: (map['user_id'] ?? map['userId']) as String? ?? '',
      title: map['title'] as String? ?? '',
      category: HabitCategory.fromString(
        (map['category'] as String?) ?? 'study',
      ),
      completed: map['completed'] as bool? ?? false,
      xpReward: (map['xp_reward'] ?? map['xpReward']) as int? ?? 25,
      createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
      completedAt:
          completedAtRaw != null ? DateTime.tryParse(completedAtRaw) : null,
    );
  }
}
