import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/models/mood.dart';

/// Visual and copy configuration for each player mood.
class MoodThemeData {
  const MoodThemeData({
    required this.primary,
    required this.secondary,
    required this.gradientColors,
    required this.motivationalText,
    required this.recommendedTasks,
    required this.icon,
    required this.questSectionTitle,
  });

  final Color primary;
  final Color secondary;
  final List<Color> gradientColors;
  final String motivationalText;
  final List<String> recommendedTasks;
  final IconData icon;
  final String questSectionTitle;

  BoxDecoration get backgroundDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      );
}

/// Mood-specific colors, gradients, and motivational copy.
class MoodTheme {
  MoodTheme._();

  static MoodThemeData forMood(Mood mood) {
    switch (mood) {
      case Mood.motivated:
        return const MoodThemeData(
          primary: Color(0xFFFF5722),
          secondary: Color(0xFFFF9800),
          gradientColors: [
            Color(0xFF1A0A00),
            Color(0xFF4A1500),
            Color(0xFF2A0800),
            Color(0xFF1A0A00),
          ],
          motivationalText:
              'Your fire burns bright! Tackle the hardest quests and claim epic rewards.',
          recommendedTasks: [
            'Long study session (60 min)',
            'Challenging workout',
            'Complete 3 hard habits',
          ],
          icon: Icons.local_fire_department,
          questSectionTitle: 'Harder Quests',
        );
      case Mood.tired:
        return const MoodThemeData(
          primary: Color(0xFF5C7CFA),
          secondary: Color(0xFF9775FA),
          gradientColors: [
            Color(0xFF0A0E1A),
            Color(0xFF1A1F4A),
            Color(0xFF121832),
            Color(0xFF0A0E1A),
          ],
          motivationalText:
              'Rest is part of the journey. Small wins still count — go easy on yourself.',
          recommendedTasks: [
            'Read 5 pages',
            'Drink a glass of water',
            '5-minute stretch',
          ],
          icon: Icons.nights_stay,
          questSectionTitle: 'Easy Quests',
        );
      case Mood.stressed:
        return const MoodThemeData(
          primary: Color(0xFF20C997),
          secondary: Color(0xFF38D9A9),
          gradientColors: [
            Color(0xFF0A1A14),
            Color(0xFF0D3328),
            Color(0xFF0A2820),
            Color(0xFF0A1A14),
          ],
          motivationalText:
              'Breathe. Wellness quests restore your spirit and sharpen your focus.',
          recommendedTasks: [
            'Meditate 10 minutes',
            'Deep breathing exercise',
            'Journal your thoughts',
          ],
          icon: Icons.spa,
          questSectionTitle: 'Wellness Quests',
        );
      case Mood.happy:
        return const MoodThemeData(
          primary: Color(0xFFFFD43B),
          secondary: Color(0xFFF59F00),
          gradientColors: [
            Color(0xFF1A1500),
            Color(0xFF4A3A00),
            Color(0xFF3A2E00),
            Color(0xFF1A1500),
          ],
          motivationalText:
              'Celebrate your momentum! Bonus quests and creative challenges await.',
          recommendedTasks: [
            'Extra XP challenge',
            'Creative side project',
            'Share a win with a friend',
          ],
          icon: Icons.celebration,
          questSectionTitle: 'Bonus Quests',
        );
    }
  }
}

/// Pulsing mood icon for animated mood UI.
class MoodAnimatedIcon extends StatefulWidget {
  const MoodAnimatedIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 28,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  State<MoodAnimatedIcon> createState() => _MoodAnimatedIconState();
}

class _MoodAnimatedIconState extends State<MoodAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}
