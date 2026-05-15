import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/services/user_service.dart';
import 'package:mini_habit_rpg/utils/xp_calculator.dart';

/// Loads and updates the user's RPG profile from Firestore.
class UserProvider extends ChangeNotifier {
  UserProvider({UserService? userService})
      : _userService = userService ?? UserService();

  final UserService _userService;

  UserProfile? _profile;
  bool _loading = false;
  String? _error;
  StreamSubscription<UserProfile?>? _subscription;

  UserProfile? get profile => _profile;
  bool get isLoading => _loading;
  String? get error => _error;

  bool get needsOnboarding {
    final p = _profile;
    if (p == null) return false;
    return p.username == 'Adventurer' || p.username.isEmpty;
  }

  Future<void> listenToUser(String uid) async {
    await _subscription?.cancel();
    _loading = true;
    notifyListeners();

    try {
      _profile = await _userService.getOrCreateProfile(uid);
      _loading = false;
      notifyListeners();

      _subscription = _userService.watchProfile(uid).listen((profile) {
        if (profile != null) {
          _profile = profile;
          notifyListeners();
        }
      });
    } catch (e) {
      _error = 'Failed to load profile.';
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding({
    required String uid,
    required String username,
    required int avatarId,
    required PersonalityArchetype archetype,
  }) async {
    await _userService.completeOnboarding(
      uid: uid,
      username: username,
      avatarId: avatarId,
      archetype: archetype,
    );
    _profile = await _userService.getOrCreateProfile(uid);
    notifyListeners();
  }

  Future<bool> applyHabitXp(int xpReward) async {
    final current = _profile;
    if (current == null) return false;

    var updated = XpCalculator.updateStreak(current);
    final result = XpCalculator.applyXp(updated, xpReward);
    updated = result.profile;

    await _userService.saveProfile(updated);
    _profile = updated;
    notifyListeners();
    return result.leveledUp;
  }

  void reset() {
    _subscription?.cancel();
    _profile = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
