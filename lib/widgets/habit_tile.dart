import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/habit.dart';

/// Single habit row with complete and delete actions.
class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: habit.completed
                    ? accent
                    : Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: habit.completed ? accent : Colors.white24,
                  width: 2,
                ),
              ),
              child: habit.completed
                  ? const Icon(Icons.check, color: Colors.white, size: 22)
                  : null,
            ),
          ),
          title: Text(
            habit.title,
            style: TextStyle(
              decoration:
                  habit.completed ? TextDecoration.lineThrough : null,
              color: habit.completed ? Colors.white54 : null,
            ),
          ),
          subtitle: Text(
            '+${habit.xpReward} XP',
            style: TextStyle(color: accent.withValues(alpha: 0.8)),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
