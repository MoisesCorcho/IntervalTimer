import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// A surface-elevated container card for grouping related settings options.
///
/// Implements the Material 3 Inset Grouped Section Card pattern with rounded
/// corners, subtle perimeter border, surface container contrast, and an optional
/// header with semantic icon and bold title.
class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    this.icon,
    this.title,
    required this.child,
  });

  /// Optional icon displayed alongside the section title.
  final IconData? icon;

  /// Optional title displayed at the top of the card.
  final String? title;

  /// The child content of the section card.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null || icon != null) ...[
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    if (title != null) const SizedBox(width: AppTheme.spacingSm),
                  ],
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
