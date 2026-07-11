import 'dart:async';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';

class LoginRewardRepository {
  LoginRewardRepository({DemoDataStore? store})
      : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;

  Future<Map<String, dynamic>?> getRewardState(String userId) async {
    if (SupabaseService.isReady) {
      final client = SupabaseService.client;
      final response = await client
          .from('user_login_rewards')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (response == null) return null;
      return Map<String, dynamic>.from(response);
    }
    await _store.ensureLoaded();
    return _store.loginRewardsByUser[userId];
  }

  Future<void> saveRewardState({
    required String userId,
    required String lastClaimedDate,
    required int consecutiveDays,
  }) async {
    final data = {
      'user_id': userId,
      'last_claimed_date': lastClaimedDate,
      'consecutive_days': consecutiveDays,
    };

    if (SupabaseService.isReady) {
      final client = SupabaseService.client;
      await client.from('user_login_rewards').upsert(data);
      return;
    }

    await _store.ensureLoaded();
    _store.loginRewardsByUser[userId] = data;
    await _store.persist();
  }

  Future<void> clearRewardState(String userId) async {
    if (SupabaseService.isReady) {
      final client = SupabaseService.client;
      await client.from('user_login_rewards').delete().eq('user_id', userId);
      return;
    }

    await _store.ensureLoaded();
    _store.loginRewardsByUser.remove(userId);
    await _store.persist();
  }
}
