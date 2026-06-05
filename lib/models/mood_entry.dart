import 'package:mini_habit_rpg/models/mood.dart';

/// A single mood selection stored in history.
class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.userId,
    required this.mood,
    required this.recordedAt,
  });

  final String id;
  final String userId;
  final Mood mood;
  final DateTime recordedAt;

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'mood': mood.name,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(String id, Map<String, dynamic> map) {
    return MoodEntry(
      id: id,
      userId: map['user_id'] as String? ?? '',
      mood: Mood.fromString(map['mood'] as String?),
      recordedAt: DateTime.tryParse(map['recorded_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
