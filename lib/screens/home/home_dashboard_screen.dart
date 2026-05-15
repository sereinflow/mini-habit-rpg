import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/providers/habit_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/screens/profile/profile_screen.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/utils/quotes.dart';
import 'package:mini_habit_rpg/widgets/character_card.dart';
import 'package:mini_habit_rpg/widgets/habit_tile.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// Main RPG dashboard — character, habits, quote, archetype.
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
    final habitProvider = context.read<HabitProvider>();

    final title = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => const _NewQuestDialog(),
    );

    if (!mounted || title == null || title.trim().isEmpty) return;

    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    await habitProvider.addHabit(title);
  }

  Future<void> _onHabitToggle(Habit habit) async {
    final habitProvider = context.read<HabitProvider>();
    final userProvider = context.read<UserProvider>();

    final completed = await habitProvider.toggleComplete(habit);
    if (completed == null || !mounted) return;

    final leveledUp = await userProvider.applyHabitXp(completed.xpReward);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+${completed.xpReward} XP earned!'),
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
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final profile = userProvider.profile;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground(profile.archetype),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {},
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: const Text('Quest Board'),
                  actions: [
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
                            "Today's Quests",
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

/// Dialog with its own controller lifecycle (avoids dispose during route pop).
class _NewQuestDialog extends StatefulWidget {
  const _NewQuestDialog();

  @override
  State<_NewQuestDialog> createState() => _NewQuestDialogState();
}

class _NewQuestDialogState extends State<_NewQuestDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Quest'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'e.g. Read 10 pages',
        ),
        onSubmitted: (_) => _submit(),
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
