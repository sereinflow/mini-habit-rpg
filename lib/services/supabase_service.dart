import 'package:mini_habit_rpg/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes and exposes the Supabase client singleton.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || !AppConfig.useSupabase) return;

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return Supabase.instance.client;
  }

  static bool get isReady => _initialized;
}
