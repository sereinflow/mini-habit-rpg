import 'package:mini_habit_rpg/models/personality_archetype.dart';

/// User RPG profile stored in Supabase `profiles` or local demo store.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.personalityTitle,
    required this.avatarId,
    required this.level,
    required this.xp,
    required this.coins,
    required this.streak,
    required this.longestStreak,
    required this.scholarPoints,
    required this.warriorPoints,
    required this.artistPoints,
    required this.totalHabitsCompleted,
    required this.totalXpEarned,
    required this.archetype,
    this.lastActiveDate,
  });

  final String uid;
  final String username;
  final String displayName;
  final String personalityTitle;
  final int avatarId;
  final int level;
  final int xp;
  final int coins;
  final int streak;
  final int longestStreak;
  final int scholarPoints;
  final int warriorPoints;
  final int artistPoints;
  final int totalHabitsCompleted;
  final int totalXpEarned;
  final PersonalityArchetype archetype;
  final String? lastActiveDate;

  int get xpToNextLevel => level * 100;

  double get xpProgress {
    if (xpToNextLevel <= 0) return 0;
    return (xp / xpToNextLevel).clamp(0.0, 1.0);
  }

  bool get needsOnboarding =>
      username.isEmpty || username == 'Adventurer';

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? personalityTitle,
    int? avatarId,
    int? level,
    int? xp,
    int? coins,
    int? streak,
    int? longestStreak,
    int? scholarPoints,
    int? warriorPoints,
    int? artistPoints,
    int? totalHabitsCompleted,
    int? totalXpEarned,
    PersonalityArchetype? archetype,
    String? lastActiveDate,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      personalityTitle: personalityTitle ?? this.personalityTitle,
      avatarId: avatarId ?? this.avatarId,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      scholarPoints: scholarPoints ?? this.scholarPoints,
      warriorPoints: warriorPoints ?? this.warriorPoints,
      artistPoints: artistPoints ?? this.artistPoints,
      totalHabitsCompleted:
          totalHabitsCompleted ?? this.totalHabitsCompleted,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      archetype: archetype ?? this.archetype,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'username': username,
      'display_name': displayName,
      'personality_title': personalityTitle,
      'avatar': avatarId,
      'level': level,
      'xp': xp,
      'coins': coins,
      'streak': streak,
      'longest_streak': longestStreak,
      'scholar_points': scholarPoints,
      'warrior_points': warriorPoints,
      'artist_points': artistPoints,
      'total_habits_completed': totalHabitsCompleted,
      'total_xp_earned': totalXpEarned,
      'archetype': archetype.name,
      'last_active_date': lastActiveDate,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      username: map['username'] as String? ?? 'Adventurer',
      displayName: (map['display_name'] ?? map['displayName'] ?? map['username']) as String? ?? 'Adventurer',
      personalityTitle: (map['personality_title'] ?? map['personalityTitle'] ?? 'Novice Questor') as String,
      avatarId: (map['avatar'] ?? map['avatarId']) as int? ?? 0,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      coins: map['coins'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      longestStreak:
          (map['longest_streak'] ?? map['longestStreak']) as int? ?? 0,
      scholarPoints:
          (map['scholar_points'] ?? map['scholarPoints']) as int? ?? 0,
      warriorPoints:
          (map['warrior_points'] ?? map['warriorPoints']) as int? ?? 0,
      artistPoints:
          (map['artist_points'] ?? map['artistPoints']) as int? ?? 0,
      totalHabitsCompleted:
          (map['total_habits_completed'] ?? map['totalHabitsCompleted'])
              as int? ??
          0,
      totalXpEarned:
          (map['total_xp_earned'] ?? map['totalXpEarned']) as int? ?? 0,
      archetype: PersonalityArchetype.fromString(map['archetype'] as String?),
      lastActiveDate:
          (map['last_active_date'] ?? map['lastActiveDate']) as String?,
    );
  }

  static UserProfile initial(String uid) {
    return UserProfile(
      uid: uid,
      username: 'Adventurer',
      displayName: 'Adventurer',
      personalityTitle: 'Novice Questor',
      avatarId: 0,
      level: 1,
      xp: 0,
      coins: 0,
      streak: 0,
      longestStreak: 0,
      scholarPoints: 0,
      warriorPoints: 0,
      artistPoints: 0,
      totalHabitsCompleted: 0,
      totalXpEarned: 0,
      archetype: PersonalityArchetype.warrior,
    );
  }
}
