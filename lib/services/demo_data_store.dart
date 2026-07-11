import 'dart:async';
import 'dart:convert';

import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/app_user.dart';
import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/models/inventory_item.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/models/mood_entry.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/quest_type.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage for demo mode (persists all game data on device).
class DemoDataStore {
  DemoDataStore._();
  static final DemoDataStore instance = DemoDataStore._();

  static const _accountsKey = 'demo_accounts';
  static const _profilesKey = 'demo_profiles';
  static const _habitsKey = 'demo_habits';
  static const _questsKey = 'demo_quests';
  static const _achievementsKey = 'demo_achievements';
  static const _moodHistoryKey = 'demo_mood_history';
  static const _currentMoodKey = 'demo_current_mood';
  static const _inventoryKey = 'demo_inventory';
  static const _loginRewardsKey = 'demo_login_rewards';

  final Map<String, UserProfile> profiles = {};
  final Map<String, List<Habit>> habitsByUser = {};
  final Map<String, List<DailyQuest>> questsByUser = {};
  final Map<String, List<UserAchievement>> achievementsByUser = {};
  final Map<String, List<MoodEntry>> moodHistoryByUser = {};
  final Map<String, Mood> currentMoodByUser = {};
  final Map<String, List<UserInventoryItem>> inventoryByUser = {};
  final Map<String, Map<String, dynamic>> loginRewardsByUser = {};
  final Map<String, String> emailToUid = {};
  final Map<String, String> emailToPassword = {};

  AppUser? currentUser;
  bool _loaded = false;

  final _authController = StreamController<AppUser?>.broadcast();
  final _profileControllers = <String, StreamController<UserProfile?>>{};
  final _habitControllers = <String, StreamController<List<Habit>>>{};
  final _questControllers = <String, StreamController<List<DailyQuest>>>{};
  final _achievementControllers =
      <String, StreamController<List<UserAchievement>>>{};
  final _moodControllers = <String, StreamController<List<MoodEntry>>>{};
  final _inventoryControllers =
      <String, StreamController<List<UserInventoryItem>>>{};

  Stream<AppUser?> get authStateChanges => _authController.stream;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final accountsRaw = prefs.getString(_accountsKey);
    if (accountsRaw != null) {
      final map = jsonDecode(accountsRaw) as Map<String, dynamic>;
      emailToUid.clear();
      emailToPassword.clear();
      for (final entry in map.entries) {
        final data = entry.value as Map<String, dynamic>;
        emailToUid[entry.key] = data['uid'] as String;
        emailToPassword[entry.key] = data['password'] as String;
      }
    }

    final profilesRaw = prefs.getString(_profilesKey);
    if (profilesRaw != null) {
      final map = jsonDecode(profilesRaw) as Map<String, dynamic>;
      profiles.clear();
      for (final entry in map.entries) {
        profiles[entry.key] =
            _profileFromJson(entry.value as Map<String, dynamic>);
      }
    }

    final habitsRaw = prefs.getString(_habitsKey);
    if (habitsRaw != null) {
      final map = jsonDecode(habitsRaw) as Map<String, dynamic>;
      habitsByUser.clear();
      for (final entry in map.entries) {
        final list = (entry.value as List<dynamic>)
            .map((e) => _habitFromJson(e as Map<String, dynamic>))
            .toList();
        habitsByUser[entry.key] = list;
      }
    }

    final questsRaw = prefs.getString(_questsKey);
    if (questsRaw != null) {
      final map = jsonDecode(questsRaw) as Map<String, dynamic>;
      questsByUser.clear();
      for (final entry in map.entries) {
        questsByUser[entry.key] = (entry.value as List<dynamic>)
            .map((e) => _questFromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    final achievementsRaw = prefs.getString(_achievementsKey);
    if (achievementsRaw != null) {
      final map = jsonDecode(achievementsRaw) as Map<String, dynamic>;
      achievementsByUser.clear();
      for (final entry in map.entries) {
        achievementsByUser[entry.key] = (entry.value as List<dynamic>)
            .map((e) => _achievementFromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    final moodRaw = prefs.getString(_moodHistoryKey);
    if (moodRaw != null) {
      final map = jsonDecode(moodRaw) as Map<String, dynamic>;
      moodHistoryByUser.clear();
      for (final entry in map.entries) {
        moodHistoryByUser[entry.key] = (entry.value as List<dynamic>)
            .map((e) => _moodFromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    final currentMoodRaw = prefs.getString(_currentMoodKey);
    if (currentMoodRaw != null) {
      final map = jsonDecode(currentMoodRaw) as Map<String, dynamic>;
      currentMoodByUser.clear();
      for (final entry in map.entries) {
        currentMoodByUser[entry.key] =
            Mood.fromString(entry.value as String?);
      }
    }

    final inventoryRaw = prefs.getString(_inventoryKey);
    if (inventoryRaw != null) {
      final map = jsonDecode(inventoryRaw) as Map<String, dynamic>;
      inventoryByUser.clear();
      for (final entry in map.entries) {
        final list = (entry.value as List<dynamic>)
            .map((e) => UserInventoryItem.fromMap(e['id'] as String, e as Map<String, dynamic>))
            .toList();
        inventoryByUser[entry.key] = list;
      }
    }

    final loginRewardsRaw = prefs.getString(_loginRewardsKey);
    if (loginRewardsRaw != null) {
      final map = jsonDecode(loginRewardsRaw) as Map<String, dynamic>;
      loginRewardsByUser.clear();
      for (final entry in map.entries) {
        loginRewardsByUser[entry.key] = entry.value as Map<String, dynamic>;
      }
    }

    _loaded = true;
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();

    final accounts = <String, dynamic>{};
    for (final email in emailToUid.keys) {
      accounts[email] = {
        'uid': emailToUid[email],
        'password': emailToPassword[email],
      };
    }
    await prefs.setString(_accountsKey, jsonEncode(accounts));

    final profilesJson = <String, dynamic>{};
    for (final entry in profiles.entries) {
      profilesJson[entry.key] = _profileToJson(entry.value);
    }
    await prefs.setString(_profilesKey, jsonEncode(profilesJson));

    final habitsJson = <String, dynamic>{};
    for (final entry in habitsByUser.entries) {
      habitsJson[entry.key] = entry.value.map(_habitToJson).toList();
    }
    await prefs.setString(_habitsKey, jsonEncode(habitsJson));

    final questsJson = <String, dynamic>{};
    for (final entry in questsByUser.entries) {
      questsJson[entry.key] = entry.value.map(_questToJson).toList();
    }
    await prefs.setString(_questsKey, jsonEncode(questsJson));

    final achievementsJson = <String, dynamic>{};
    for (final entry in achievementsByUser.entries) {
      achievementsJson[entry.key] =
          entry.value.map(_achievementToJson).toList();
    }
    await prefs.setString(_achievementsKey, jsonEncode(achievementsJson));

    final moodJson = <String, dynamic>{};
    for (final entry in moodHistoryByUser.entries) {
      moodJson[entry.key] = entry.value.map(_moodToJson).toList();
    }
    await prefs.setString(_moodHistoryKey, jsonEncode(moodJson));

    final currentMoodJson = <String, dynamic>{};
    for (final entry in currentMoodByUser.entries) {
      currentMoodJson[entry.key] = entry.value.name;
    }
    await prefs.setString(_currentMoodKey, jsonEncode(currentMoodJson));

    final inventoryJson = <String, dynamic>{};
    for (final entry in inventoryByUser.entries) {
      inventoryJson[entry.key] = entry.value.map((i) => i.toMap()).toList();
    }
    await prefs.setString(_inventoryKey, jsonEncode(inventoryJson));

    final loginRewardsJson = <String, dynamic>{};
    for (final entry in loginRewardsByUser.entries) {
      loginRewardsJson[entry.key] = entry.value;
    }
    await prefs.setString(_loginRewardsKey, jsonEncode(loginRewardsJson));

    _loaded = true;
  }

  Future<void> registerAccount({
    required String email,
    required String password,
    required AppUser user,
  }) async {
    await ensureLoaded();
    emailToUid[email] = user.uid;
    emailToPassword[email] = password;
    profiles[user.uid] = UserProfile.initial(user.uid);
    habitsByUser.putIfAbsent(user.uid, () => []);
    questsByUser.putIfAbsent(user.uid, () => []);
    achievementsByUser.putIfAbsent(user.uid, () => []);
    moodHistoryByUser.putIfAbsent(user.uid, () => []);
    inventoryByUser.putIfAbsent(user.uid, () => []);
    await persist();
  }

  bool verifyLogin(String email, String password) {
    final uid = emailToUid[email];
    if (uid == null) return false;
    return emailToPassword[email] == password;
  }

  void emitAuth(AppUser? user) {
    currentUser = user;
    _authController.add(user);
  }

  StreamController<UserProfile?> profileController(String uid) {
    return _profileControllers.putIfAbsent(
      uid,
      () => StreamController<UserProfile?>.broadcast(),
    );
  }

  StreamController<List<Habit>> habitController(String uid) {
    return _habitControllers.putIfAbsent(
      uid,
      () => StreamController<List<Habit>>.broadcast(),
    );
  }

  StreamController<List<DailyQuest>> questController(String uid) {
    return _questControllers.putIfAbsent(
      uid,
      () => StreamController<List<DailyQuest>>.broadcast(),
    );
  }

  StreamController<List<UserAchievement>> achievementController(String uid) {
    return _achievementControllers.putIfAbsent(
      uid,
      () => StreamController<List<UserAchievement>>.broadcast(),
    );
  }

  StreamController<List<MoodEntry>> moodController(String uid) {
    return _moodControllers.putIfAbsent(
      uid,
      () => StreamController<List<MoodEntry>>.broadcast(),
    );
  }

  StreamController<List<UserInventoryItem>> inventoryController(String uid) {
    return _inventoryControllers.putIfAbsent(
      uid,
      () => StreamController<List<UserInventoryItem>>.broadcast(),
    );
  }

  Future<void> emitProfile(UserProfile profile) async {
    profiles[profile.uid] = profile;
    final controller = profileController(profile.uid);
    if (!controller.isClosed) controller.add(profile);
    await persist();
  }

  void pushHabitsToStream(String uid) {
    final list = List<Habit>.from(habitsByUser[uid] ?? []);
    list.sort((a, b) => a.title.compareTo(b.title));
    final controller = habitController(uid);
    if (!controller.isClosed) controller.add(list);
  }

  Future<void> emitHabits(String uid) async {
    pushHabitsToStream(uid);
    await persist();
  }

  void pushQuestsToStream(String uid) {
    final list = List<DailyQuest>.from(questsByUser[uid] ?? []);
    final controller = questController(uid);
    if (!controller.isClosed) controller.add(list);
  }

  Future<void> emitQuests(String uid) async {
    pushQuestsToStream(uid);
    await persist();
  }

  void pushAchievementsToStream(String uid) {
    final list = List<UserAchievement>.from(achievementsByUser[uid] ?? []);
    final controller = achievementController(uid);
    if (!controller.isClosed) controller.add(list);
  }

  Future<void> emitAchievements(String uid) async {
    pushAchievementsToStream(uid);
    await persist();
  }

  void pushMoodHistoryToStream(String uid) {
    final list = List<MoodEntry>.from(moodHistoryByUser[uid] ?? []);
    final controller = moodController(uid);
    if (!controller.isClosed) controller.add(list);
  }

  Future<void> emitMoodHistory(String uid) async {
    pushMoodHistoryToStream(uid);
    await persist();
  }

  void pushInventoryToStream(String uid) {
    final list = List<UserInventoryItem>.from(inventoryByUser[uid] ?? []);
    final controller = inventoryController(uid);
    if (!controller.isClosed) controller.add(list);
  }

  Future<void> emitInventory(String uid) async {
    pushInventoryToStream(uid);
    await persist();
  }

  List<Habit> habitsFor(String uid) => habitsByUser[uid] ?? [];
  List<DailyQuest> questsFor(String uid) => questsByUser[uid] ?? [];
  List<UserAchievement> achievementsFor(String uid) =>
      achievementsByUser[uid] ?? [];
  List<UserInventoryItem> inventoryFor(String uid) =>
      inventoryByUser[uid] ?? [];

  Map<String, dynamic> _profileToJson(UserProfile p) => {
        'uid': p.uid,
        'username': p.username,
        'displayName': p.displayName,
        'personalityTitle': p.personalityTitle,
        'avatarId': p.avatarId,
        'level': p.level,
        'xp': p.xp,
        'coins': p.coins,
        'streak': p.streak,
        'longestStreak': p.longestStreak,
        'scholarPoints': p.scholarPoints,
        'warriorPoints': p.warriorPoints,
        'artistPoints': p.artistPoints,
        'totalHabitsCompleted': p.totalHabitsCompleted,
        'totalXpEarned': p.totalXpEarned,
        'archetype': p.archetype.name,
        'lastActiveDate': p.lastActiveDate,
      };

  UserProfile _profileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      username: json['username'] as String? ?? 'Adventurer',
      displayName: json['displayName'] as String? ?? json['username'] as String? ?? 'Adventurer',
      personalityTitle: json['personalityTitle'] as String? ?? 'Novice Questor',
      avatarId: json['avatarId'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      scholarPoints: json['scholarPoints'] as int? ?? 0,
      warriorPoints: json['warriorPoints'] as int? ?? 0,
      artistPoints: json['artistPoints'] as int? ?? 0,
      totalHabitsCompleted: json['totalHabitsCompleted'] as int? ?? 0,
      totalXpEarned: json['totalXpEarned'] as int? ?? 0,
      archetype:
          PersonalityArchetype.fromString(json['archetype'] as String?),
      lastActiveDate: json['lastActiveDate'] as String?,
    );
  }

  Map<String, dynamic> _habitToJson(Habit h) => {
        'id': h.id,
        'userId': h.userId,
        'title': h.title,
        'category': h.category.name,
        'completed': h.completed,
        'xpReward': h.xpReward,
        'createdAt': h.createdAt?.toIso8601String(),
        'completedAt': h.completedAt?.toIso8601String(),
      };

  Habit _habitFromJson(Map<String, dynamic> json) {
    final completedAtRaw = json['completedAt'] as String?;
    final createdAtRaw = json['createdAt'] as String?;
    return Habit(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: HabitCategory.fromString(json['category'] as String?),
      completed: json['completed'] as bool? ?? false,
      xpReward: json['xpReward'] as int? ?? 25,
      createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
      completedAt:
          completedAtRaw != null ? DateTime.tryParse(completedAtRaw) : null,
    );
  }

  Map<String, dynamic> _questToJson(DailyQuest q) => {
        'id': q.id,
        'userId': q.userId,
        'title': q.title,
        'xpReward': q.xpReward,
        'coinReward': q.coinReward,
        'completed': q.completed,
        'questDate': q.questDate,
        'questType': q.questType.name,
        if (q.mood != null) 'mood': q.mood!.name,
      };

  DailyQuest _questFromJson(Map<String, dynamic> json) {
    return DailyQuest(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      xpReward: json['xpReward'] as int? ?? 50,
      coinReward: json['coinReward'] as int? ?? 10,
      completed: json['completed'] as bool? ?? false,
      questDate: json['questDate'] as String? ?? '',
      questType: QuestType.fromString(json['questType'] as String?),
      mood: json['mood'] != null
          ? Mood.fromString(json['mood'] as String?)
          : null,
    );
  }

  Map<String, dynamic> _achievementToJson(UserAchievement a) => {
        'id': a.id,
        'userId': a.userId,
        'achievementName': a.achievementName,
        'unlocked': a.unlocked,
        'unlockedAt': a.unlockedAt?.toIso8601String(),
      };

  UserAchievement _achievementFromJson(Map<String, dynamic> json) {
    final unlockedAtRaw = json['unlockedAt'] as String?;
    return UserAchievement(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      achievementName: json['achievementName'] as String? ?? '',
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt:
          unlockedAtRaw != null ? DateTime.tryParse(unlockedAtRaw) : null,
    );
  }

  Map<String, dynamic> _moodToJson(MoodEntry m) => {
        'id': m.id,
        'userId': m.userId,
        'mood': m.mood.name,
        'recordedAt': m.recordedAt.toIso8601String(),
      };

  MoodEntry _moodFromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      mood: Mood.fromString(json['mood'] as String?),
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Future<void> clearAllUserData(String uid) async {
    profiles[uid] = UserProfile.initial(uid);
    habitsByUser[uid] = [];
    questsByUser[uid] = [];
    achievementsByUser[uid] = [];
    moodHistoryByUser[uid] = [];
    inventoryByUser[uid] = [];
    loginRewardsByUser.remove(uid);
    currentMoodByUser[uid] = Mood.motivated;

    final pController = profileController(uid);
    if (!pController.isClosed) pController.add(profiles[uid]);

    final hController = habitController(uid);
    if (!hController.isClosed) hController.add([]);

    final qController = questController(uid);
    if (!qController.isClosed) qController.add([]);

    final aController = achievementController(uid);
    if (!aController.isClosed) aController.add([]);

    final mController = moodController(uid);
    if (!mController.isClosed) mController.add([]);

    final iController = inventoryController(uid);
    if (!iController.isClosed) iController.add([]);

    await persist();
  }
}
