import 'dart:async';
import 'dart:convert';

import 'package:mini_habit_rpg/models/app_user.dart';
import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage for demo mode (persists accounts, profiles, habits on device).
class DemoDataStore {
  DemoDataStore._();
  static final DemoDataStore instance = DemoDataStore._();

  static const _accountsKey = 'demo_accounts';
  static const _profilesKey = 'demo_profiles';
  static const _habitsKey = 'demo_habits';

  final Map<String, UserProfile> profiles = {};
  final Map<String, List<Habit>> habitsByUser = {};
  final Map<String, String> emailToUid = {};
  final Map<String, String> emailToPassword = {};

  AppUser? currentUser;
  bool _loaded = false;

  final _authController = StreamController<AppUser?>.broadcast();
  final _profileControllers = <String, StreamController<UserProfile?>>{};
  final _habitControllers = <String, StreamController<List<Habit>>>{};

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
        profiles[entry.key] = _profileFromJson(entry.value as Map<String, dynamic>);
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
      habitsJson[entry.key] =
          entry.value.map(_habitToJson).toList();
    }
    await prefs.setString(_habitsKey, jsonEncode(habitsJson));
  }

  Future<void> registerAccount({
    required String email,
    required String password,
    required AppUser user,
  }) async {
    await ensureLoaded();
    emailToUid[email] = user.uid;
    emailToPassword[email] = password;
    final initial = UserProfile.initial(user.uid);
    profiles[user.uid] = initial;
    habitsByUser.putIfAbsent(user.uid, () => []);
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

  Future<void> emitProfile(UserProfile profile) async {
    profiles[profile.uid] = profile;
    final controller = profileController(profile.uid);
    if (!controller.isClosed) {
      controller.add(profile);
    }
    await persist();
  }

  void pushHabitsToStream(String uid) {
    final list = List<Habit>.from(habitsByUser[uid] ?? []);
    list.sort((a, b) => a.title.compareTo(b.title));
    final controller = habitController(uid);
    if (!controller.isClosed) {
      controller.add(list);
    }
  }

  Future<void> emitHabits(String uid) async {
    pushHabitsToStream(uid);
    await persist();
  }

  List<Habit> habitsFor(String uid) => habitsByUser[uid] ?? [];

  Map<String, dynamic> _profileToJson(UserProfile p) => {
        'uid': p.uid,
        'username': p.username,
        'avatarId': p.avatarId,
        'level': p.level,
        'xp': p.xp,
        'streak': p.streak,
        'archetype': p.archetype.name,
        'lastActiveDate': p.lastActiveDate,
      };

  UserProfile _profileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      username: json['username'] as String? ?? 'Adventurer',
      avatarId: json['avatarId'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      archetype: PersonalityArchetype.fromString(json['archetype'] as String?),
      lastActiveDate: json['lastActiveDate'] as String?,
    );
  }

  Map<String, dynamic> _habitToJson(Habit h) => {
        'id': h.id,
        'userId': h.userId,
        'title': h.title,
        'completed': h.completed,
        'xpReward': h.xpReward,
        'completedAt': h.completedAt?.toIso8601String(),
      };

  Habit _habitFromJson(Map<String, dynamic> json) {
    final completedAtRaw = json['completedAt'] as String?;
    return Habit(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      xpReward: json['xpReward'] as int? ?? 25,
      completedAt:
          completedAtRaw != null ? DateTime.tryParse(completedAtRaw) : null,
    );
  }
}
