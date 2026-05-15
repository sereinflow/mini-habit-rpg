import 'package:flutter/foundation.dart';
import 'package:mini_habit_rpg/models/app_user.dart';
import 'package:mini_habit_rpg/services/auth_service.dart';

/// Exposes auth state and login/signup/logout actions to the UI.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _user = _authService.currentUser;
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthService _authService;

  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _loading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    return _runAuth(
      () => _authService.signUp(email: email, password: password),
    );
  }

  Future<bool> signIn(String email, String password) async {
    return _runAuth(
      () => _authService.signIn(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> _runAuth(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await action();
      _loading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _authService.mapAuthError(e);
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
