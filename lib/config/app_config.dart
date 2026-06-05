/// App configuration — toggle demo mode vs Supabase backend.
class AppConfig {
  AppConfig._();

  /// `true` = local SharedPreferences demo. `false` = Supabase cloud.
  static const bool demoMode = false;

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get useSupabase =>
      !demoMode && supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static const int defaultCoinReward = 5;
  static const int questCoinMultiplier = 2;
}
