import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/personality_archetype.dart';
import 'package:mini_habit_rpg/providers/auth_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/utils/constants.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';

/// First-time setup: username, avatar, and personality path.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _usernameController = TextEditingController();
  int _avatarId = 0;
  PersonalityArchetype _archetype = PersonalityArchetype.warrior;
  bool _saving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final name = _usernameController.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username must be at least 2 characters')),
      );
      return;
    }

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    await context.read<UserProvider>().completeOnboarding(
          uid: uid,
          username: name,
          avatarId: _avatarId,
          archetype: _archetype,
        );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentFor(_archetype);

    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground(_archetype),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose Your Path',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your archetype shapes your quest theme.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                ...PersonalityArchetype.values.map((a) {
                  final selected = _archetype == a;
                  final color = AppTheme.accentFor(a);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RpgCard(
                      accentColor: color,
                      onTap: () => setState(() => _archetype = a),
                      child: Row(
                        children: [
                          Text(a.emoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selected ? color : null,
                                  ),
                                ),
                                Text(
                                  a.tagline,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle, color: color),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Hero Name (Username)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Select Avatar', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(AppConstants.avatarEmojis.length, (i) {
                    final selected = _avatarId == i;
                    return GestureDetector(
                      onTap: () => setState(() => _avatarId = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? accent.withValues(alpha: 0.3)
                              : Colors.white10,
                          border: Border.all(
                            color: selected ? accent : Colors.white24,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppConstants.avatarEmojis[i],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saving ? null : _finish,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Start Your Quest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
