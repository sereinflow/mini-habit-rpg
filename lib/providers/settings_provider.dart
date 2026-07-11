import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _loadSettings();
  }

  static const _themeModeKey = 'settings_theme_mode';
  static const _soundKey = 'settings_sound_enabled';
  static const _notificationsKey = 'settings_notifications_enabled';

  ThemeMode _themeMode = ThemeMode.dark;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get isSoundEnabled => _soundEnabled;
  bool get isNotificationsEnabled => _notificationsEnabled;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeModeKey);
    if (modeString != null) {
      _themeMode = modeString == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
    _soundEnabled = prefs.getBool(_soundKey) ?? true;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeMode == ThemeMode.light ? 'light' : 'dark');
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, _soundEnabled);
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, _notificationsEnabled);
  }

  Future<void> resetAllSettings() async {
    _themeMode = ThemeMode.dark;
    _soundEnabled = true;
    _notificationsEnabled = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeModeKey);
    await prefs.remove(_soundKey);
    await prefs.remove(_notificationsKey);
  }
}
