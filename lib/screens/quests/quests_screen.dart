import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/daily_quest.dart';
import 'package:mini_habit_rpg/models/mood.dart';
import 'package:mini_habit_rpg/providers/daily_quest_provider.dart';
import 'package:mini_habit_rpg/providers/mood_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/theme/mood_theme.dart';
import 'package:mini_habit_rpg/widgets/daily_quest_tile.dart';
import 'package:mini_habit_rpg/widgets/mood_selector.dart';
import 'package:mini_habit_rpg/widgets/recommended_tasks_panel.dart';

/// Daily quests tab — mood-themed UI with mood-specific generated quests.
class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  Future<void> _onMoodSelected(BuildContext context, Mood mood) async {
    final questProvider = context.read<DailyQuestProvider>();
    await context.read<MoodProvider>().selectMood(mood);
    await questProvider.regenerateForMood(mood);
  }

  Future<void> _onQuestComplete(BuildContext context, DailyQuest quest) async {
    final questProvider = context.read<DailyQuestProvider>();
    final userProvider = context.read<UserProvider>();
    final moodTheme = MoodTheme.forMood(
      context.read<MoodProvider>().currentMood ?? Mood.motivated,
    );

    final completed = await questProvider.completeQuest(quest);
    if (completed == null || !context.mounted) return;

    final reward = await userProvider.applyQuestReward(
      xpReward: completed.xpReward,
      coinReward: completed.coinReward,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Quest complete! +${completed.xpReward} XP · +${completed.coinReward} coins',
        ),
        backgroundColor: moodTheme.primary,
      ),
    );

    if (reward.leveledUp) {
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
    final questProvider = context.watch<DailyQuestProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final mood = moodProvider.currentMood ?? Mood.motivated;
    final moodTheme = MoodTheme.forMood(mood);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: moodTheme.backgroundDecoration,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _onMoodSelected(context, mood);
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  title: const Text('Daily Quests'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      MoodSelector(
                        selected: moodProvider.currentMood,
                        moodTheme: moodTheme,
                        onSelected: (m) => _onMoodSelected(context, m),
                      ),
                      const SizedBox(height: 16),
                      RecommendedTasksPanel(theme: moodTheme),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            moodTheme.questSectionTitle,
                            style: Theme.of(context).textTheme.titleMedium,
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
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Select a mood to generate quests.'),
                        )
                      else
                        ...questProvider.quests.map(
                          (q) => DailyQuestTile(
                            key: ValueKey(q.id),
                            quest: q,
                            highlighted: true,
                            accentColor: moodTheme.primary,
                            onComplete: () => _onQuestComplete(context, q),
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
    );
  }
}
