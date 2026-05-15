import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';

/// User profile storage — local demo (no Firestore).
class UserService {
  UserService({DemoDataStore? store}) : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;

  Future<UserProfile> getOrCreateProfile(String uid) async {
    await _store.ensureLoaded();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final existing = _store.profiles[uid];
    if (existing != null) return existing;

    final initial = UserProfile.initial(uid);
    await _store.emitProfile(initial);
    return initial;
  }

  Stream<UserProfile?> watchProfile(String uid) {
    final controller = _store.profileController(uid);
    Future.microtask(() => controller.add(_store.profiles[uid]));
    return controller.stream;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await _store.emitProfile(profile);
  }

  Future<void> completeOnboarding({
    required String uid,
    required String username,
    required int avatarId,
    required PersonalityArchetype archetype,
  }) async {
    final current = _store.profiles[uid] ?? UserProfile.initial(uid);
    final updated = current.copyWith(
      username: username,
      avatarId: avatarId,
      archetype: archetype,
      level: 1,
      xp: 0,
      streak: 0,
    );
    await saveProfile(updated);
  }
}
