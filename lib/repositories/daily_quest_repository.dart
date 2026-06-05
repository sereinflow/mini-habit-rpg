import 'dart:math';

import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';
import 'package:mini_habit_rpg/utils/daily_quest_generator.dart';
import 'package:mini_habit_rpg/utils/xp_calculator.dart';

/// Daily quest persistence and generation.
class DailyQuestRepository {
  DailyQuestRepository({DemoDataStore? store})
      : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;

  Stream<List<DailyQuest>> watch(String userId) {
    if (SupabaseService.isReady) {
      return _watchSupabase(userId);
    }
    final controller = _store.questController(userId);
    Future.microtask(() => _store.pushQuestsToStream(userId));
    return controller.stream;
  }

  Future<List<DailyQuest>> ensureTodayQuests(String userId) async {
    final today = XpCalculator.todayKey();
    final existing = await _fetchForDate(userId, today);

    if (existing.isNotEmpty) return existing;

    final quests = DailyQuestGenerator.generate(
      userId: userId,
      random: Random(userId.hashCode + DateTime.now().day),
    );

    if (SupabaseService.isReady) {
      final saved = <DailyQuest>[];
      for (final quest in quests) {
        final row = await SupabaseService.client
            .from('daily_quests')
            .insert(quest.toMap())
            .select()
            .single();
        saved.add(DailyQuest.fromMap(
          row['id'] as String,
          Map<String, dynamic>.from(row),
        ));
      }
      return saved;
    }

    _store.questsByUser.putIfAbsent(userId, () => []).addAll(quests);
    await _store.emitQuests(userId);
    return quests;
  }

  Future<void> update(DailyQuest quest) async {
    if (SupabaseService.isReady) {
      await SupabaseService.client
          .from('daily_quests')
          .update(quest.toMap())
          .eq('id', quest.id);
      return;
    }

    final list = _store.questsFor(quest.userId);
    final index = list.indexWhere((q) => q.id == quest.id);
    if (index >= 0) {
      list[index] = quest;
      await _store.emitQuests(quest.userId);
    }
  }

  Future<List<DailyQuest>> _fetchForDate(String userId, String date) async {
    if (SupabaseService.isReady) {
      final rows = await SupabaseService.client
          .from('daily_quests')
          .select()
          .eq('user_id', userId)
          .eq('quest_date', date);
      return (rows as List<dynamic>)
          .map((r) => DailyQuest.fromMap(
                r['id'] as String,
                Map<String, dynamic>.from(r as Map),
              ))
          .toList();
    }

    return _store
        .questsFor(userId)
        .where((q) => q.questDate == date)
        .toList();
  }

  Stream<List<DailyQuest>> _watchSupabase(String userId) async* {
    await ensureTodayQuests(userId);

    while (true) {
      final today = XpCalculator.todayKey();
      yield await _fetchForDate(userId, today);
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
}
