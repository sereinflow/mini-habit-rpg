import 'package:mini_habit_rpg/models/personality_archetype.dart';

/// User RPG profile stored in Firestore under `users/{uid}`.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.username,
    required this.avatarId,
    required this.level,
    required this.xp,
    required this.streak,
    required this.archetype,
    this.lastActiveDate,
  });

  final String uid;
  final String username;
  final int avatarId;
  final int level;
  final int xp;
  final int streak;
  final PersonalityArchetype archetype;
  final String? lastActiveDate;

  /// XP required to reach the next level (simple scaling formula).
  int get xpToNextLevel => level * 100;

  double get xpProgress {
    if (xpToNextLevel <= 0) return 0;
    return (xp / xpToNextLevel).clamp(0.0, 1.0);
  }

  bool get needsOnboarding =>
      username.isEmpty || username == 'Adventurer';

  UserProfile copyWith({
    String? username,
    int? avatarId,
    int? level,
    int? xp,
    int? streak,
    PersonalityArchetype? archetype,
    String? lastActiveDate,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      avatarId: avatarId ?? this.avatarId,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      archetype: archetype ?? this.archetype,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'avatarId': avatarId,
      'level': level,
      'xp': xp,
      'streak': streak,
      'archetype': archetype.name,
      'lastActiveDate': lastActiveDate,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      username: map['username'] as String? ?? 'Adventurer',
      avatarId: map['avatarId'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      archetype: PersonalityArchetype.fromString(map['archetype'] as String?),
      lastActiveDate: map['lastActiveDate'] as String?,
    );
  }

  static UserProfile initial(String uid) {
    return UserProfile(
      uid: uid,
      username: 'Adventurer',
      avatarId: 0,
      level: 1,
      xp: 0,
      streak: 0,
      archetype: PersonalityArchetype.warrior,
    );
  }
}
