import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/app.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';

/// App entry point — loads local demo data, then launches the RPG app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DemoDataStore.instance.load();
  runApp(const MiniHabitRpgApp());
}
