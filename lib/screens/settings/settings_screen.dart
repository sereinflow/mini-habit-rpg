import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/providers/auth_provider.dart';
import 'package:mini_habit_rpg/providers/settings_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/theme/app_theme.dart';
import 'package:mini_habit_rpg/widgets/rpg_card.dart';
import 'package:mini_habit_rpg/utils/constants.dart';
import 'package:mini_habit_rpg/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realm Settings'),
      ),
      body: Container(
        height: double.infinity,
        decoration: profile != null
            ? AppTheme.gradientBackground(profile.archetype)
            : null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Profile Settings
              RpgCard(
                accentColor: Theme.of(context).colorScheme.primary,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  title: const Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Customize name, avatar, and title'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 2. Password & Security
              RpgCard(
                accentColor: Colors.orangeAccent,
                child: ListTile(
                  leading: const Icon(Icons.security, color: Colors.orangeAccent),
                  title: const Text('Password & Security', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Manage password, session, and account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 3. Privacy Settings
              RpgCard(
                accentColor: Colors.tealAccent,
                child: ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.tealAccent),
                  title: const Text('Privacy & Policies', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('View Privacy Policy and Terms'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 4. About settings
              RpgCard(
                accentColor: Colors.purpleAccent,
                child: ListTile(
                  leading: const Icon(Icons.info, color: Colors.purpleAccent),
                  title: const Text('About Mini Habit RPG', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('App details and credits'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutSettingsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Reset progress (Danger zone)
              RpgCard(
                accentColor: Colors.redAccent,
                child: ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.redAccent),
                  title: const Text(
                    'Reset All Progress',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Delete progress and start over'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _resetProgress(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetProgress(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Danger Zone'),
        content: const Text(
          'Are you sure you want to RESET all your progress? '
          'This will permanently delete all your habits, quests, achievements, coins, and levels. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('RESET EVERYTHING'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final userProvider = context.read<UserProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await userProvider.resetProgress();
      await settingsProvider.resetAllSettings();

      navigator.pop(); // Close loading indicator
      navigator.pop(); // Go back to profile screen
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Your journey has been reset.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to reset progress. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 1. PROFILE SETTINGS SCREEN
// ---------------------------------------------------------------------------
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _titleController;
  late int _selectedAvatarId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _displayNameController = TextEditingController(text: profile?.displayName ?? '');
    _titleController = TextEditingController(text: profile?.personalityTitle ?? '');
    _selectedAvatarId = profile?.avatarId ?? 0;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await context.read<UserProvider>().updateProfile(
            username: _usernameController.text.trim(),
            displayName: _displayNameController.text.trim(),
            personalityTitle: _titleController.text.trim(),
            avatarId: _selectedAvatarId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;
    final authEmail = SupabaseService.isReady 
        ? (SupabaseService.client.auth.currentUser?.email ?? 'Unknown') 
        : 'demo@example.com';

    if (profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar selector
              Center(
                child: Column(
                  children: [
                    Text(
                      AppConstants.avatarEmojis[_selectedAvatarId],
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 8),
                    const Text('Select Avatar Emoji', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(AppConstants.avatarEmojis.length, (idx) {
                  final isSelected = idx == _selectedAvatarId;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _selectedAvatarId = idx),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) 
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Text(AppConstants.avatarEmojis[idx], style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Form fields
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name', prefixIcon: Icon(Icons.badge)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Display name cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Username cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Personality Title (Display only)', prefixIcon: Icon(Icons.workspace_premium)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Personality title cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: authEmail,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Account Email', 
                  prefixIcon: Icon(Icons.email),
                  helperText: 'Manage this in Auth Provider Settings',
                ),
              ),
              const SizedBox(height: 32),

              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Save Changes'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. PASSWORD & SECURITY SCREEN
// ---------------------------------------------------------------------------
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUpdating = true);

    final pass = _passwordController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      if (SupabaseService.isReady) {
        await SupabaseService.client.auth.updateUser(
          UserAttributes(password: pass),
        );
      }
      _passwordController.clear();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _sendResetEmail() async {
    setState(() => _isUpdating = true);
    final messenger = ScaffoldMessenger.of(context);
    final authEmail = SupabaseService.isReady 
        ? SupabaseService.client.auth.currentUser?.email 
        : null;

    try {
      if (SupabaseService.isReady && authEmail != null) {
        await SupabaseService.client.auth.resetPasswordForEmail(authEmail);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $authEmail!'),
            backgroundColor: Colors.teal,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Demo Mode: Reset email sent to demo@example.com!'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave the Realm?'),
        content: const Text('You will be signed out of your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    // Pop screens back to Dashboard
    navigator.pop(); // Pop security settings
    navigator.pop(); // Pop main settings
    await authProvider.signOut();
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔥 Permanently Delete Account?'),
        content: const Text(
          'This action is IRREVERSIBLE. It will delete your profile data, achievements, and quest history. '
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE PERMANENTLY'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final uid = userProvider.profile?.uid;
      if (uid != null) {
        if (SupabaseService.isReady) {
          // Delete tables first
          final client = SupabaseService.client;
          await Future.wait([
            client.from('habits').delete().eq('user_id', uid),
            client.from('daily_quests').delete().eq('user_id', uid),
            client.from('achievements').delete().eq('user_id', uid),
            client.from('user_inventory').delete().eq('user_id', uid),
            client.from('user_login_rewards').delete().eq('user_id', uid),
            client.from('mood_history').delete().eq('user_id', uid),
            client.from('profiles').delete().eq('id', uid),
          ]);
        }
      }

      navigator.pop(); // Pop security screen
      navigator.pop(); // Pop settings screen
      await authProvider.signOut();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Your account has been deleted.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error deleting account: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password & Security')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Change Password Form
            RpgCard(
              accentColor: Colors.orangeAccent,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (val) => val == null || val.length < 6 
                            ? 'Password must be at least 6 characters' 
                            : null,
                      ),
                      const SizedBox(height: 16),
                      if (_isUpdating)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: _changePassword,
                          child: const Text('Update Password'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reset password via email
            RpgCard(
              accentColor: Colors.tealAccent,
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.tealAccent),
                title: const Text('Send Password Reset Email', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Sends email link to reset login credentials'),
                onTap: _isUpdating ? null : _sendResetEmail,
              ),
            ),
            const SizedBox(height: 16),

            // Logout card
            RpgCard(
              accentColor: Colors.blueAccent,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.blueAccent),
                title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Sign out of your current session'),
                onTap: _logout,
              ),
            ),
            const SizedBox(height: 16),

            // Danger zone delete account card
            RpgCard(
              accentColor: Colors.redAccent,
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                subtitle: const Text('Permanently erase all your user records'),
                onTap: _deleteAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. PRIVACY SETTINGS SCREEN
// ---------------------------------------------------------------------------
class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  Widget _buildSection(BuildContext context, String title, String content) {
    return RpgCard(
      accentColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Policies')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              context,
              'Privacy Policy',
              'We value your privacy. Mini Habit RPG does not sell, trade, or share your personal database records with third-party networks. All your completed habits, profile statistics, and daily quest history are secured using standard encryption algorithms. If you connect to Supabase Cloud, your authentication tokens are handled securely by Supabase IAM policies.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Terms & Conditions',
              'By accessing and using Mini Habit RPG, you agree to comply with our gaming standards. Play honestly and track your daily activities constructively. Cheating coins or modifying local database records using memory inspectors violates game policy and may affect your global profile leaderboard stats.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Data Usage Information',
              'This application stores local data in your device memory via SharedPreferences to support offline demo operations. When Cloud Sync is activated, your profile data, achievements list, active shop customizations, and daily quest status are backed up to Supabase. You can permanently wipe this data at any time from the "Password & Security" tab.',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. ABOUT SETTINGS SCREEN
// ---------------------------------------------------------------------------
class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '⚔️',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                'Mini Habit RPG',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Version 1.0',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              RpgCard(
                accentColor: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'DEVELOPED BY:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sumaiya Tabassum\nRifah Tasnia Risha',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 20),
                      const Text(
                        'FACULTY / INSTITUTION:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Department of CSE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                '© 2026 Mini Habit RPG. All Rights Reserved.',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
