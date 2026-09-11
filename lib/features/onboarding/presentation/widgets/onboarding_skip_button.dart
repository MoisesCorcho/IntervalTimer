import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

class OnboardingSkipButton extends StatelessWidget {
  const OnboardingSkipButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingSm),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        child: const Text('Saltar'),
      ),
    );
  }
}
