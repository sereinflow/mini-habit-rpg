import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/app.dart';
import 'package:mini_habit_rpg/config/app_config.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';

/// App entry point — initializes backend, then launches the RPG app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.useSupabase) {
    await SupabaseService.initialize();
  } else {
    if (!AppConfig.demoMode) {
      // demoMode is false but dart-defines were not passed — falls back to local storage.
      debugPrint(
        '⚠️ Supabase not configured. Pass SUPABASE_URL and SUPABASE_ANON_KEY '
        'via --dart-define when running. Using local demo storage instead.',
      );
    }
    await DemoDataStore.instance.load();
  }

  runApp(const MiniHabitRpgApp());
}
