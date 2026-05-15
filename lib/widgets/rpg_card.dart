import 'package:flutter/material.dart';

/// Reusable card with subtle RPG border glow.
class RpgCard extends StatelessWidget {
  const RpgCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accentColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? Theme.of(context).colorScheme.primary;

    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
