import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';

/// Achievement unlock persistence.
class AchievementRepository {
  AchievementRepository({DemoDataStore? store})
      : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;

  Stream<List<UserAchievement>> watch(String userId) {
    if (SupabaseService.isReady) {
      return _watchSupabase(userId);
    }
    final controller = _store.achievementController(userId);
    Future.microtask(() => _store.pushAchievementsToStream(userId));
    return controller.stream;
  }

  Future<List<UserAchievement>> getAll(String userId) async {
    if (SupabaseService.isReady) {
      final rows = await SupabaseService.client
          .from('achievements')
          .select()
          .eq('user_id', userId);
      return (rows as List<dynamic>)
          .map((r) => UserAchievement.fromMap(
                r['id'] as String,
                Map<String, dynamic>.from(r as Map),
              ))
          .toList();
    }
    return List.from(_store.achievementsFor(userId));
  }

  Future<UserAchievement> unlock({
    required String userId,
    required AchievementType type,
  }) async {
    final achievement = UserAchievement(
      id: 'ach_${type.id}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      achievementName: type.id,
      unlocked: true,
      unlockedAt: DateTime.now(),
    );

    if (SupabaseService.isReady) {
      final existing = await SupabaseService.client
          .from('achievements')
          .select()
          .eq('user_id', userId)
          .eq('achievement_name', type.id)
          .maybeSingle();

      if (existing != null) {
        return UserAchievement.fromMap(
          existing['id'] as String,
          Map<String, dynamic>.from(existing),
        );
      }

      final row = await SupabaseService.client
          .from('achievements')
          .insert(achievement.toMap())
          .select()
          .single();
      return UserAchievement.fromMap(
        row['id'] as String,
        Map<String, dynamic>.from(row),
      );
    }

    final list = _store.achievementsFor(userId);
    if (list.any((a) => a.achievementName == type.id)) {
      return list.firstWhere((a) => a.achievementName == type.id);
    }
    list.add(achievement);
    await _store.emitAchievements(userId);
    return achievement;
  }

  Stream<List<UserAchievement>> _watchSupabase(String userId) async* {
    yield await getAll(userId);
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 3));
      yield await getAll(userId);
    }
  }
}
