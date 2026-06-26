import 'dart:math';

import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';
import 'package:mini_habit_rpg/utils/daily_quest_generator.dart';
import 'package:mini_habit_rpg/utils/xp_calculator.dart';

/// Daily quest persistence and mood-based generation.
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

  Future<List<DailyQuest>> ensureTodayQuests(
    String userId, {
    Mood? mood,
  }) async {
    final today = XpCalculator.todayKey();
    final effectiveMood = mood ?? Mood.motivated;
    final existing = await _fetchForDate(userId, today);

    if (existing.isNotEmpty) {
      final moods = existing
          .where((q) => q.mood != null)
          .map((q) => q.mood)
          .toSet();
      if (moods.length == 1 && moods.first == effectiveMood) {
        return existing;
      }
    }

    return regenerateForMood(userId, effectiveMood);
  }

  /// Replaces incomplete today quests with a fresh mood-specific set.
  Future<List<DailyQuest>> regenerateForMood(
    String userId,
    Mood mood,
  ) async {
    final today = XpCalculator.todayKey();
    final existing = await _fetchForDate(userId, today);
    final completed = existing.where((q) => q.completed).toList();
    final toRemove = existing.where((q) => !q.completed).toList();

    await _deleteQuests(userId, toRemove.map((q) => q.id).toList());

    final random = Random(userId.hashCode + mood.index + DateTime.now().day);
    final fresh = DailyQuestGenerator.generateForMood(
      userId: userId,
      mood: mood,
      random: random,
    );

    final saved = <DailyQuest>[];
    for (final quest in fresh) {
      saved.add(await _insertQuest(quest));
    }

    final result = [...completed, ...saved];
    await _emit(userId, result);
    return result;
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

  Future<DailyQuest> _insertQuest(DailyQuest quest) async {
    if (SupabaseService.isReady) {
      final row = await SupabaseService.client
          .from('daily_quests')
          .insert(quest.toMap())
          .select()
          .single();
      return DailyQuest.fromMap(
        row['id'] as String,
        Map<String, dynamic>.from(row),
      );
    }

    _store.questsByUser.putIfAbsent(quest.userId, () => []).add(quest);
    return quest;
  }

  Future<void> _deleteQuests(String userId, List<String> ids) async {
    if (ids.isEmpty) return;

    if (SupabaseService.isReady) {
      for (final id in ids) {
        await SupabaseService.client
            .from('daily_quests')
            .delete()
            .eq('id', id);
      }
      return;
    }

    final list = _store.questsByUser[userId];
    if (list != null) {
      list.removeWhere((q) => ids.contains(q.id));
      await _store.emitQuests(userId);
    }
  }

  Future<void> _emit(String userId, List<DailyQuest> quests) async {
    if (SupabaseService.isReady) return;

    final today = XpCalculator.todayKey();
    final all = _store.questsFor(userId);
    all.removeWhere((q) => q.questDate == today);
    all.addAll(quests);
    _store.questsByUser[userId] = all;
    await _store.emitQuests(userId);
  }

  Stream<List<DailyQuest>> _watchSupabase(String userId) async* {
    while (true) {
      final today = XpCalculator.todayKey();
      yield await _fetchForDate(userId, today);
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
}
