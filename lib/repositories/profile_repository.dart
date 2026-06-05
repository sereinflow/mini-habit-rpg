import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Profile persistence — demo store or Supabase `profiles` table.
class ProfileRepository {
  ProfileRepository({DemoDataStore? store})
      : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;

  Future<UserProfile> getOrCreate(String uid) async {
    if (SupabaseService.isReady) {
      return _getOrCreateSupabase(uid);
    }
    return _getOrCreateDemo(uid);
  }

  Stream<UserProfile?> watch(String uid) {
    if (SupabaseService.isReady) {
      return _watchSupabase(uid);
    }
    final controller = _store.profileController(uid);
    Future.microtask(() => controller.add(_store.profiles[uid]));
    return controller.stream;
  }

  Future<void> save(UserProfile profile) async {
    if (SupabaseService.isReady) {
      await SupabaseService.client
          .from('profiles')
          .upsert(profile.toMap());
      return;
    }
    await _store.emitProfile(profile);
  }

  Future<void> completeOnboarding({
    required String uid,
    required String username,
    required int avatarId,
    required PersonalityArchetype archetype,
  }) async {
    final current = await getOrCreate(uid);
    await save(current.copyWith(
      username: username,
      avatarId: avatarId,
      archetype: archetype,
      level: 1,
      xp: 0,
      coins: 0,
      streak: 0,
    ));
  }

  Future<UserProfile> _getOrCreateDemo(String uid) async {
    await _store.ensureLoaded();
    final existing = _store.profiles[uid];
    if (existing != null) return existing;
    final initial = UserProfile.initial(uid);
    await _store.emitProfile(initial);
    return initial;
  }

  Future<UserProfile> _getOrCreateSupabase(String uid) async {
    final client = SupabaseService.client;
    final row = await client.from('profiles').select().eq('id', uid).maybeSingle();

    if (row != null) {
      return UserProfile.fromMap(uid, Map<String, dynamic>.from(row));
    }

    final initial = UserProfile.initial(uid);
    await client.from('profiles').insert(initial.toMap());
    return initial;
  }

  Stream<UserProfile?> _watchSupabase(String uid) async* {
    yield await _getOrCreateSupabase(uid);

    final channel = SupabaseService.client
        .channel('profile_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: uid,
          ),
          callback: (_) {},
        )
        .subscribe();

    try {
      while (true) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final row = await SupabaseService.client
            .from('profiles')
            .select()
            .eq('id', uid)
            .maybeSingle();
        if (row != null) {
          yield UserProfile.fromMap(uid, Map<String, dynamic>.from(row));
        }
      }
    } finally {
      await SupabaseService.client.removeChannel(channel);
    }
  }
}
