import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';

/// Firestore operations for `users/{uid}` documents.
class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _users.doc(uid);

  Future<UserProfile> getOrCreateProfile(String uid) async {
    final snap = await _doc(uid).get();
    if (snap.exists && snap.data() != null) {
      return UserProfile.fromMap(uid, snap.data()!);
    }

    final initial = UserProfile.initial(uid);
    await _doc(uid).set(initial.toMap());
    return initial;
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> completeOnboarding({
    required String uid,
    required String username,
    required int avatarId,
    required PersonalityArchetype archetype,
  }) async {
    await _doc(uid).set({
      'username': username,
      'avatarId': avatarId,
      'archetype': archetype.name,
      'level': 1,
      'xp': 0,
      'streak': 0,
    }, SetOptions(merge: true));
  }
}
