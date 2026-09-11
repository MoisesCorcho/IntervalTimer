import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// Semantic notification type for [AppSnackBar].
enum AppSnackBarType {
  success,
  error,
  warning,
  info,
}

/// Centralized Design System helper for premium floating SnackBars.
///
/// Features:
/// - Semantic iconography (success, error, warning, info).
/// - Tactile micro-haptic feedback.
/// - Inherits floating geometry, contrast and typography from [AppTheme.snackBarTheme].
/// - Safe integration with [ScaffoldMessenger].
abstract final class AppSnackBar {
  /// Shows a styled SnackBar with an icon and optional action button.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    _triggerHaptic(type);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final theme = Theme.of(context);
    final iconData = _iconFor(type);
    final iconColor = _iconColorFor(type, theme.colorScheme);

    final snackBar = SnackBar(
      duration: duration,
      showCloseIcon: true,
      content: Row(
        children: [
          Icon(
            iconData,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: AppTheme.spacingSm + 4), // 12dp
          Expanded(
            child: Text(
              message,
              style: theme.snackBarTheme.contentTextStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onActionPressed,
            )
          : null,
    );

    return messenger.showSnackBar(snackBar);
  }

  /// Displays a success feedback SnackBar with haptic pulse.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccess(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    return show(
      context,
      message: message,
      type: AppSnackBarType.success,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Displays an error feedback SnackBar with haptic pulse.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    return show(
      context,
      message: message,
      type: AppSnackBarType.error,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Displays an info feedback SnackBar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfo(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    return show(
      context,
      message: message,
      type: AppSnackBarType.info,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  static void _triggerHaptic(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        HapticFeedback.lightImpact();
      case AppSnackBarType.error:
      case AppSnackBarType.warning:
        HapticFeedback.mediumImpact();
      case AppSnackBarType.info:
        HapticFeedback.selectionClick();
    }
  }

  static IconData _iconFor(AppSnackBarType type) {
    return switch (type) {
      AppSnackBarType.success => Icons.check_circle_rounded,
      AppSnackBarType.error => Icons.error_outline_rounded,
      AppSnackBarType.warning => Icons.warning_amber_rounded,
      AppSnackBarType.info => Icons.info_outline_rounded,
    };
  }

  static Color _iconColorFor(AppSnackBarType type, ColorScheme colorScheme) {
    return switch (type) {
      AppSnackBarType.success => colorScheme.primary,
      AppSnackBarType.error => const Color(0xFFEF5350),   // Red
      AppSnackBarType.warning => const Color(0xFFFFB74D), // Amber
      AppSnackBarType.info => colorScheme.primary,
    };
  }
}
