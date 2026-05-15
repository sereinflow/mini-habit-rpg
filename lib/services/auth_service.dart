import 'package:mini_habit_rpg/models/app_user.dart';
import 'package:mini_habit_rpg/services/demo_data_store.dart';

/// Thrown when demo sign-in / sign-up validation fails.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}

/// Email/password auth — local demo storage (no Firebase).
class AuthService {
  AuthService({DemoDataStore? store}) : _store = store ?? DemoDataStore.instance;

  final DemoDataStore _store;

  Stream<AppUser?> get authStateChanges => _store.authStateChanges;

  AppUser? get currentUser => _store.currentUser;

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _store.ensureLoaded();
    final normalized = email.trim().toLowerCase();
    _validateCredentials(normalized, password);

    if (_store.emailToUid.containsKey(normalized)) {
      throw AuthException('This email is already registered.');
    }

    final user = AppUser(uid: _uidForEmail(normalized), email: normalized);
    await _store.registerAccount(
      email: normalized,
      password: password,
      user: user,
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _store.emitAuth(user);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _store.ensureLoaded();
    final normalized = email.trim().toLowerCase();
    _validateCredentials(normalized, password);

    if (!_store.verifyLogin(normalized, password)) {
      throw AuthException('Invalid email or password.');
    }

    final uid = _store.emailToUid[normalized]!;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _store.emitAuth(AppUser(uid: uid, email: normalized));
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _store.emitAuth(null);
  }

  String? mapAuthError(AuthException e) => e.message;

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
