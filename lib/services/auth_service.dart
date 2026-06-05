import 'package:mini_habit_rpg/models/app_user.dart';
import 'package:mini_habit_rpg/models/user_profile.dart';
import 'package:mini_habit_rpg/repositories/profile_repository.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thrown when sign-in / sign-up validation fails.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}

/// Email/password auth — demo store or Supabase Auth.
class AuthService {
  AuthService({
    DemoDataStore? store,
    ProfileRepository? profileRepository,
  })  : _store = store ?? DemoDataStore.instance,
        _profiles = profileRepository ?? ProfileRepository();

  final DemoDataStore _store;
  final ProfileRepository _profiles;

  Stream<AppUser?> get authStateChanges {
    if (SupabaseService.isReady) {
      return SupabaseService.client.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        if (user == null) return null;
        return AppUser(uid: user.id, email: user.email ?? '');
      });
    }
    return _store.authStateChanges;
  }

  AppUser? get currentUser {
    if (SupabaseService.isReady) {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return null;
      return AppUser(uid: user.id, email: user.email ?? '');
    }
    return _store.currentUser;
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    _validateCredentials(normalized, password);

    if (SupabaseService.isReady) {
      final response = await SupabaseService.client.auth.signUp(
        email: normalized,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw AuthException('Sign up failed. Please try again.');
      }
      await _profiles.save(UserProfile.initial(user.id));
      return;
    }

    await _store.ensureLoaded();
    if (_store.emailToUid.containsKey(normalized)) {
      throw AuthException('This email is already registered.');
    }

    final user = AppUser(uid: _uidForEmail(normalized), email: normalized);
    await _store.registerAccount(
      email: normalized,
      password: password,
      user: user,
    );
    _store.emitAuth(user);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    _validateCredentials(normalized, password);

    if (SupabaseService.isReady) {
      await SupabaseService.client.auth.signInWithPassword(
        email: normalized,
        password: password,
      );
      return;
    }

    await _store.ensureLoaded();
    if (!_store.verifyLogin(normalized, password)) {
      throw AuthException('Invalid email or password.');
    }

    final uid = _store.emailToUid[normalized]!;
    _store.emitAuth(AppUser(uid: uid, email: normalized));
  }

  Future<void> signOut() async {
    if (SupabaseService.isReady) {
      await SupabaseService.client.auth.signOut();
      return;
    }
    _store.emitAuth(null);
  }

  String? mapAuthError(Object e) {
    if (e is AuthException) return e.message;
    if (e is AuthApiException) return e.message;
    return 'Authentication failed. Please try again.';
  }

  void _validateCredentials(String email, String password) {
    if (!email.contains('@')) {
      throw AuthException('Please enter a valid email address.');
    }
    if (password.length < 6) {
      throw AuthException('Password is too weak (use at least 6 characters).');
    }
  }

  String _uidForEmail(String email) => 'demo_${email.hashCode.abs()}';
}
