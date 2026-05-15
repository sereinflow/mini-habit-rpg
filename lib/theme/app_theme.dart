import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';

/// Dark fantasy RPG palette with archetype accent colors.
class AppTheme {
  AppTheme._();

  static const Color _background = Color(0xFF0D0F14);
  static const Color _surface = Color(0xFF1A1F2E);
  static const Color _card = Color(0xFF232A3D);

  static Color accentFor(PersonalityArchetype archetype) {
    switch (archetype) {
      case PersonalityArchetype.scholar:
        return const Color(0xFF5C7CFA);
      case PersonalityArchetype.warrior:
        return const Color(0xFFE03131);
      case PersonalityArchetype.artist:
        return const Color(0xFFF59F00);
    }
  }

  static Color secondaryFor(PersonalityArchetype archetype) {
    switch (archetype) {
      case PersonalityArchetype.scholar:
        return const Color(0xFF9775FA);
      case PersonalityArchetype.warrior:
        return const Color(0xFFFF6B6B);
      case PersonalityArchetype.artist:
        return const Color(0xFF20C997);
    }
  }

  static ThemeData dark(PersonalityArchetype archetype) {
    final accent = accentFor(archetype);
    final secondary = secondaryFor(archetype);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: secondary,
        surface: _surface,
        onPrimary: Colors.white,
        onSurface: const Color(0xFFE8E8F0),
      ),
      cardTheme: CardThemeData(
        color: _card,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.cinzelTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFE8E8F0),
        displayColor: Colors.white,
      ),
    );
  }

  static BoxDecoration gradientBackground(PersonalityArchetype archetype) {
    final accent = accentFor(archetype);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0D0F14),
          accent.withValues(alpha: 0.15),
          const Color(0xFF0D0F14),
        ],
      ),
    );
  }
}
