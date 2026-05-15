import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_habit_rpg/models/habit.dart';
import 'package:mini_habit_rpg/utils/constants.dart';

/// Firestore CRUD for `habits` collection (filtered by userId).
class HabitService {
  HabitService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _habits =>
      _firestore.collection('habits');

  Stream<List<Habit>> watchHabits(String userId) {
    return _habits
        .where('userId', isEqualTo: userId)
        .orderBy('title')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Habit.fromMap(d.id, d.data()))
            .toList());
  }

  Future<Habit> addHabit({
    required String userId,
    required String title,
  }) async {
    final doc = _habits.doc();
    final habit = Habit(
      id: doc.id,
      userId: userId,
      title: title.trim(),
      completed: false,
      xpReward: AppConstants.defaultHabitXp,
    );
    await doc.set(habit.toMap());
    return habit;
  }

  Future<void> updateHabit(Habit habit) async {
    await _habits.doc(habit.id).update(habit.toMap());
  }

  Future<void> deleteHabit(String habitId) async {
    await _habits.doc(habitId).delete();
  }
}
