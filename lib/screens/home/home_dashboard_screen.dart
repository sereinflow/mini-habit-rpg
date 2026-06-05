import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/providers/daily_quest_provider.dart';
import 'package:mini_habit_rpg/providers/habit_provider.dart';
import 'package:mini_habit_rpg/providers/mood_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/screens/profile/profile_screen.dart';
import 'package:mini_habit_rpg/screens/stats/statistics_screen.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/utils/mood_recommender.dart';
import 'package:mini_habit_rpg/utils/quotes.dart';
import 'package:mini_habit_rpg/widgets/character_card.dart';
import 'package:mini_habit_rpg/widgets/daily_quest_tile.dart';
import 'package:mini_habit_rpg/widgets/habit_tile.dart';
import 'package:mini_habit_rpg/widgets/mood_selector.dart';
import 'package:mini_habit_rpg/widgets/personality_chart.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Main RPG dashboard — character, mood, quests, habits, personality.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late final String _quote;

  @override
  void initState() {
    super.initState();
    final archetype = context.read<UserProvider>().profile?.archetype ??
        PersonalityArchetype.warrior;
    _quote = MotivationalQuotes.randomFor(archetype);
  }

  Future<void> _showAddHabitDialog() async {
    final result = await showDialog<({String title, HabitCategory category})>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => const _NewQuestDialog(),
    );

    if (!mounted || result == null || result.title.trim().isEmpty) return;
    await context.read<HabitProvider>().addHabit(result.title, result.category);
  }

  Future<void> _onHabitToggle(Habit habit) async {
    final habitProvider = context.read<HabitProvider>();
    final userProvider = context.read<UserProvider>();

    final completed = await habitProvider.toggleComplete(habit);
    if (completed == null || !mounted) return;

    final reward = await userProvider.applyHabitReward(
      xpReward: completed.xpReward,
      coinReward: completed.coinReward,
      category: completed.category,
    );

    if (!mounted) return;
    _showRewardFeedback(
      xp: completed.xpReward,
      coins: completed.coinReward,
      leveledUp: reward.leveledUp,
      achievements: reward.newAchievements,
    );
  }

  Future<void> _onQuestComplete(DailyQuest quest) async {
    final questProvider = context.read<DailyQuestProvider>();
    final userProvider = context.read<UserProvider>();

    final completed = await questProvider.completeQuest(quest);
    if (completed == null || !mounted) return;

    final reward = await userProvider.applyQuestReward(
      xpReward: completed.xpReward,
      coinReward: completed.coinReward,
    );

    if (!mounted) return;
    _showRewardFeedback(
      xp: completed.xpReward,
      coins: completed.coinReward,
      leveledUp: reward.leveledUp,
      achievements: reward.newAchievements,
      label: 'Daily quest complete!',
    );
  }

  void _showRewardFeedback({
    required int xp,
    required int coins,
    required bool leveledUp,
    required List<AchievementType> achievements,
    String label = 'Quest complete!',
  }) {
    final userProvider = context.read<UserProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label +$xp XP · +$coins coins'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    if (leveledUp) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Level Up!'),
          content: Text(
            'You reached level ${userProvider.profile?.level ?? 1}!',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }

    for (final achievement in achievements) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Achievement Unlocked!'),
          content: Text(
            '${achievement.name}\n${achievement.description}\n+${achievement.xpReward} XP · +${achievement.coinReward} coins',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Awesome'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final questProvider = context.watch<DailyQuestProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final profile = userProvider.profile;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final mood = moodProvider.currentMood ?? Mood.motivated;
    final recommended = MoodRecommender.recommend(habitProvider.habits, mood);
    final recommendedIds = recommended.map((h) => h.id).toSet();

    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground(profile.archetype),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final uid = profile.uid;
              await Future.wait([
                userProvider.listenToUser(uid),
                habitProvider.listenToHabits(uid),
                questProvider.listenToQuests(uid),
              ]);
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: const Text('Quest Board'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.bar_chart),
                      tooltip: 'Statistics',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      CharacterCard(profile: profile),
                      const SizedBox(height: 16),
                      MoodSelector(
                        selected: moodProvider.currentMood,
                        onSelected: moodProvider.selectMood,
                      ),
                      const SizedBox(height: 16),
                      PersonalityChart(profile: profile),
                      const SizedBox(height: 16),
                      RpgCard(
                        accentColor:
                            Theme.of(context).colorScheme.secondary,
                        child: Row(
                          children: [
                            const Icon(Icons.format_quote,
                                color: Colors.white38),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _quote,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Quests',
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${questProvider.completedQuests.length}/${questProvider.quests.length} done',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (questProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (questProvider.quests.isEmpty)
                        const RpgCard(
                          child: Text('Generating today\'s quests...'),
                        )
                      else
                        ...questProvider.quests.map(
                          (q) => DailyQuestTile(
                            key: ValueKey(q.id),
                            quest: q,
                            onComplete: () => _onQuestComplete(q),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            recommended.isNotEmpty
                                ? 'Recommended for ${mood.label}'
                                : "Today's Habits",
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${habitProvider.todayCompleted.length}/${habitProvider.habits.length} done',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (habitProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (habitProvider.habits.isEmpty)
                        RpgCard(
                          child: Column(
                            children: [
                              const Text('🗺️',
                                  style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              const Text('No quests yet.'),
                              const SizedBox(height: 4),
                              Text(
                                'Tap + to add your first habit.',
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      else
                        ...habitProvider.habits.map(
                          (h) => HabitTile(
                            key: ValueKey(h.id),
                            habit: h,
                            recommended: recommendedIds.contains(h.id),
                            onToggle: () => _onHabitToggle(h),
                            onDelete: () =>
                                habitProvider.deleteHabit(h.id),
                          ),
                        ),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHabitDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Quest'),
      ),
    );
  }
}

class _NewQuestDialog extends StatefulWidget {
  const _NewQuestDialog();

  @override
  State<_NewQuestDialog> createState() => _NewQuestDialogState();
}

class _NewQuestDialogState extends State<_NewQuestDialog> {
  final _controller = TextEditingController();
  HabitCategory _category = HabitCategory.study;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop((title: text, category: _category));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Quest'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Read 10 pages',
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<HabitCategory>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: HabitCategory.values
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text('${c.emoji} ${c.label}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
