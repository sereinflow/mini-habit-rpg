import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_habit_rpg/models/login_reward.dart';
import 'package:mini_habit_rpg/providers/inventory_provider.dart';
import 'package:mini_habit_rpg/providers/login_reward_provider.dart';
import 'package:mini_habit_rpg/providers/user_provider.dart';
import 'package:mini_habit_rpg/utils/xp_calculator.dart';

class LoginRewardsDialog extends StatefulWidget {
  const LoginRewardsDialog({super.key});

  static Future<void> show(BuildContext context) async {
    final loginRewardProvider = context.read<LoginRewardProvider>();
    if (!loginRewardProvider.canClaimReward) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) => const LoginRewardsDialog(),
    );
  }

  @override
  State<LoginRewardsDialog> createState() => _LoginRewardsDialogState();
}

class _LoginRewardsDialogState extends State<LoginRewardsDialog> {
  bool _isClaiming = false;

  Future<void> _claim(
      BuildContext context,
      LoginRewardProvider loginRewardProvider,
      UserProvider userProvider,
      InventoryProvider inventoryProvider) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() => _isClaiming = true);

    final reward = await loginRewardProvider.claimDailyReward(
      userProvider: userProvider,
      inventoryProvider: inventoryProvider,
    );

    if (!mounted || !context.mounted) return;
    setState(() => _isClaiming = false);

    if (reward != null) {
      navigator.pop(); // Close dialog

      String msg = 'Claimed Day ${reward.dayIndex} reward: ${reward.description}!';
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('🎉 Reward Claimed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reward.icon, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(msg, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Great!'),
            ),
          ],
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to claim reward. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginRewardProvider = context.watch<LoginRewardProvider>();
    final userProvider = context.watch<UserProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    final nextDay = loginRewardProvider.nextRewardDay;
    final canClaim = loginRewardProvider.canClaimReward;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Realm Daily Login Rewards',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Claim daily bonuses to speed up your character progression!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 7 Days rewards grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(7, (index) {
                final dayNum = index + 1;
                final reward = LoginReward.getByDay(dayNum);

                // Determine reward state: Claimed, Next Claimable, Locked
                bool isClaimed = false;
                bool isActive = false;

                if (loginRewardProvider.lastClaimedDate == XpCalculator.todayKey()) {
                  // Claimed today. All days up to consecutiveDays are claimed.
                  isClaimed = dayNum <= loginRewardProvider.consecutiveDays;
                } else {
                  // Not claimed today.
                  isClaimed = dayNum < nextDay;
                  isActive = dayNum == nextDay;
                }

                Color borderClr = Colors.transparent;
                Color cardBg = isDark ? Colors.black26 : Colors.grey[100]!;

                if (isActive) {
                  borderClr = Theme.of(context).colorScheme.primary;
                } else if (isClaimed) {
                  cardBg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[300]!;
                }

                return SizedBox(
                  width: 76,
                  height: 96,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderClr,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                reward.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Theme.of(context).colorScheme.primary : null,
                                ),
                              ),
                              Text(
                                reward.icon,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24),
                              ),
                              Text(
                                reward.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 8, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (isClaimed)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.greenAccent,
                              size: 28,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Giant claim button
            if (_isClaiming)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: canClaim
                    ? () => _claim(context, loginRewardProvider, userProvider, inventoryProvider)
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  canClaim ? 'Claim Reward' : 'Already Claimed Today',
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }
}
