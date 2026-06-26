import 'package:flutter/material.dart';
import 'package:mini_habit_rpg/screens/character/character_screen.dart';
import 'package:mini_habit_rpg/screens/home/home_dashboard_screen.dart';
import 'package:mini_habit_rpg/screens/profile/profile_screen.dart';
import 'package:mini_habit_rpg/screens/quests/quests_screen.dart';
import 'package:mini_habit_rpg/screens/stats/statistics_screen.dart';

/// Bottom navigation shell — Home, Quests, Character, Stats, Profile.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    _NavTab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavTab(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'Quests',
    ),
    _NavTab(
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield,
      label: 'Character',
    ),
    _NavTab(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Stats',
    ),
    _NavTab(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeDashboardScreen(),
          QuestsScreen(),
          CharacterScreen(),
          StatisticsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.activeIcon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
