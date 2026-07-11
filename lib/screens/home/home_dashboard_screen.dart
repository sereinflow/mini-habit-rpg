import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/achievement.dart';
import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/models/habit_category.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/shop_item.dart';
import 'package:mini_habit_rpg/providers/daily_quest_provider.dart';
import 'package:mini_habit_rpg/providers/habit_provider.dart';
import 'package:mini_habit_rpg/providers/inventory_provider.dart';
import 'package:mini_habit_rpg/providers/mood_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/screens/shop/shop_inventory_screen.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/theme/mood_theme.dart';
import 'package:mini_habit_rpg/utils/mood_recommender.dart';
import 'package:mini_habit_rpg/utils/quotes.dart';
import 'package:mini_habit_rpg/widgets/achievement_unlock_dialog.dart';
import 'package:mini_habit_rpg/widgets/character_card.dart';
import 'package:mini_habit_rpg/widgets/habit_tile.dart';
import 'package:mini_habit_rpg/widgets/login_rewards_dialog.dart';
import 'package:mini_habit_rpg/widgets/mood_selector.dart';
import 'package:mini_habit_rpg/widgets/recommended_tasks_panel.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Home tab — character summary, mood banner, recommended habits.
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
    final archetype =
        context.read<UserProvider>().profile?.archetype ??
        PersonalityArchetype.warrior;
    _quote = MotivationalQuotes.randomFor(archetype);

    // Trigger Login Reward popup on startup if claimable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LoginRewardsDialog.show(context);
    });
  }

  Future<void> _onMoodSelected(Mood mood) async {
    final questProvider = context.read<DailyQuestProvider>();
    await context.read<MoodProvider>().selectMood(mood);
    await questProvider.regenerateForMood(mood);
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
    final inventoryProvider = context.read<InventoryProvider>();

    final completed = await habitProvider.toggleComplete(habit);
    if (completed == null || !mounted) return;

    final reward = await userProvider.applyHabitReward(
      xpReward: completed.xpReward,
      coinReward: completed.coinReward,
      category: completed.category,
      inventoryProvider: inventoryProvider,
    );

    if (!mounted) return;
    _showRewardFeedback(
      xp: completed.xpReward,
      coins: completed.coinReward,
      leveledUp: reward.leveledUp,
      achievements: reward.newAchievements,
      streakShieldUsed: reward.streakShieldUsed,
    );
  }

  void _showRewardFeedback({
    required int xp,
    required int coins,
    required bool leveledUp,
    required List<AchievementType> achievements,
    required bool streakShieldUsed,
  }) {
    final userProvider = context.read<UserProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quest complete! +$xp XP · +$coins coins'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    if (streakShieldUsed) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('🛡️ Streak Shield Activated!'),
          content: const Text(
            'You missed completing quests yesterday, but your Streak Aegis shield was consumed to protect your streak!',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Phew!'),
            ),
          ],
        ),
      );
    }

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
      AchievementUnlockDialog.show(context, achievement);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final profile = userProvider.profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final mood = moodProvider.currentMood ?? Mood.motivated;
    final moodTheme = MoodTheme.forMood(mood);
    final recommended = MoodRecommender.recommend(habitProvider.habits, mood);
    final recommendedIds = recommended.map((h) => h.id).toSet();

    // Check equipped theme environment
    final equippedThemeItem = inventoryProvider.getEquipped(ShopItemType.theme);
    final activeThemeId = equippedThemeItem?.itemId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: AppTheme.environmentBackground(
          equippedThemeId: activeThemeId,
          archetype: profile.archetype,
          isDark: isDark,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final uid = profile.uid;
              await Future.wait([
                userProvider.listenToUser(uid),
                habitProvider.listenToHabits(uid),
                inventoryProvider.listenToInventory(uid),
              ]);
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  title: const Text('Quest Board'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      tooltip: 'Realm Shop',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ShopInventoryScreen(),
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

                      // Environment & Quick Shop Widget
                      RpgCard(
                        accentColor: Theme.of(context).colorScheme.primary,
                        child: Row(
                          children: [
                            const Text('🌲', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Active Environment',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                  Text(
                                    equippedThemeItem?.metadata?.name ??
                                        'Dark Abyss (Default)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ShopInventoryScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.store, size: 16),
                              label: const Text('Quick Shop', style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      MoodSelector(
                        selected: moodProvider.currentMood,
                        moodTheme: moodTheme,
                        onSelected: _onMoodSelected,
                      ),
                      const SizedBox(height: 16),
                      RecommendedTasksPanel(theme: moodTheme),
                      const SizedBox(height: 16),
                      RpgCard(
                        accentColor: moodTheme.secondary,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.format_quote,
                              color: Colors.white38,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _quote,
                                style: Theme.of(context).textTheme.bodyMedium
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
                            recommended.isNotEmpty
                                ? 'Recommended for ${mood.label}'
                                : "Today's Habits",
                            style: Theme.of(context).textTheme.titleMedium,
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
                              const Text('🗺️', style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              const Text('No quests yet.'),
                              const SizedBox(height: 4),
                              Text(
                                'Tap + to add your first habit.',
                                style: Theme.of(context).textTheme.bodySmall,
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
                            onDelete: () => habitProvider.deleteHabit(h.id),
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
            decoration: const InputDecoration(hintText: 'e.g. Read 10 pages'),
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
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
