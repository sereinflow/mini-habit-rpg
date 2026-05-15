import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/providers/auth_provider.dart';
import 'package:mini_habit_rpg/providers/habit_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/screens/auth/login_screen.dart';
import 'package:mini_habit_rpg/screens/home/home_dashboard_screen.dart';
import 'package:mini_habit_rpg/screens/onboarding/onboarding_screen.dart';
import 'package:mini_habit_rpg/screens/splash_screen.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/utils/constants.dart';
/// Root widget — routes users based on auth and onboarding state.
class MiniHabitRpgApp extends StatelessWidget {
  const MiniHabitRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: const _ThemedApp(),
    );
  }
}

class _ThemedApp extends StatelessWidget {
  const _ThemedApp();

  @override
  Widget build(BuildContext context) {
    final archetype = context.watch<UserProvider>().profile?.archetype ??
        PersonalityArchetype.warrior;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(archetype),
      home: const _AppGate(),
    );
  }
}

class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();

    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    return const _AuthenticatedGate();
  }
}

class _AuthenticatedGate extends StatefulWidget {
  const _AuthenticatedGate();

  @override
  State<_AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends State<_AuthenticatedGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  Future<void> _loadUserData() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    final userProvider = context.read<UserProvider>();
    final habitProvider = context.read<HabitProvider>();

    await userProvider.listenToUser(uid);
    if (!mounted) return;
    await habitProvider.listenToHabits(uid);

    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SplashScreen();
    }

    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading && userProvider.profile == null) {
      return const SplashScreen();
    }

    if (userProvider.needsOnboarding) {
      return const OnboardingScreen();
    }

    return const HomeDashboardScreen();
  }
}
