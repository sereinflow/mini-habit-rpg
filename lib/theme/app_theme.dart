import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';

/// Dark/Light fantasy RPG palette with archetype accent colors.
class AppTheme {
  AppTheme._();

  static const Color _darkBackground = Color(0xFF0D0F14);
  static const Color _darkSurface = Color(0xFF1A1F2E);
  static const Color _darkCard = Color(0xFF232A3D);

  static const Color _lightBackground = Color(0xFFF1F3F5);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFE9ECEF);

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
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: secondary,
        surface: _darkSurface,
        onPrimary: Colors.white,
        onSurface: const Color(0xFFE8E8F0),
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
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

  static ThemeData light(PersonalityArchetype archetype) {
    final accent = accentFor(archetype);
    final secondary = secondaryFor(archetype);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: secondary,
        surface: _lightSurface,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF212529),
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
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
        bodyColor: const Color(0xFF212529),
        displayColor: const Color(0xFF1A1D20),
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

  static BoxDecoration environmentBackground({
    String? equippedThemeId,
    required PersonalityArchetype archetype,
    required bool isDark,
  }) {
    final accent = accentFor(archetype);

    List<Color> colors;
    if (isDark) {
      switch (equippedThemeId) {
        case 'theme_forest':
          colors = [
            const Color(0xFF080F0A),
            const Color(0xFF122616),
            const Color(0xFF080F0A)
          ];
          break;
        case 'theme_ocean':
          colors = [
            const Color(0xFF050E14),
            const Color(0xFF0B1F2E),
            const Color(0xFF050E14)
          ];
          break;
        case 'theme_sunset':
          colors = [
            const Color(0xFF14080F),
            const Color(0xFF2D1116),
            const Color(0xFF14080F)
          ];
          break;
        case 'theme_crimson':
          colors = [
            const Color(0xFF140505),
            const Color(0xFF2C0B0B),
            const Color(0xFF140505)
          ];
          break;
        default:
          colors = [
            const Color(0xFF0D0F14),
            accent.withValues(alpha: 0.15),
            const Color(0xFF0D0F14)
          ];
          break;
      }
    } else {
      switch (equippedThemeId) {
        case 'theme_forest':
          colors = [
            const Color(0xFFF1F8F3),
            const Color(0xFFD3EBE0),
            const Color(0xFFF1F8F3)
          ];
          break;
        case 'theme_ocean':
          colors = [
            const Color(0xFFEBF5FB),
            const Color(0xFFCFE5F5),
            const Color(0xFFEBF5FB)
          ];
          break;
        case 'theme_sunset':
          colors = [
            const Color(0xFFFEF5F1),
            const Color(0xFFFCE1D4),
            const Color(0xFFFEF5F1)
          ];
          break;
        case 'theme_crimson':
          colors = [
            const Color(0xFFFDF2F2),
            const Color(0xFFFAD1D1),
            const Color(0xFFFDF2F2)
          ];
          break;
        default:
          colors = [
            const Color(0xFFF8F9FA),
            accent.withValues(alpha: 0.1),
            const Color(0xFFF8F9FA)
          ];
          break;
      }
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
    );
  }
}
