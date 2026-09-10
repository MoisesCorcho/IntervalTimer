import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// Standard modal bottom sheet wrapper following Design System specifications.
///
/// Centralizes:
/// - Maximum bounded height (default 85% of screen height) ensuring sheets
///   never stretch unconstrained to the top edge on tall screens (e.g. 20:9 on Poco X5 Pro).
/// - Material 3 `showDragHandle: true`.
/// - Automatic keyboard avoidance via `viewInsets.bottom`.
/// - Standard horizontal padding (`AppTheme.spacingMd` = 16dp).
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  double maxHeightFraction = 0.85,
  bool isDismissible = true,
  bool enableDrag = true,
  EdgeInsets? contentPadding,
}) {
  final mediaQuery = MediaQuery.of(context);
  final maxHeight = mediaQuery.size.height * maxHeightFraction;
  final effectivePadding = contentPadding ??
      const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingSm,
        AppTheme.spacingMd,
        0,
      );

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    constraints: BoxConstraints(
      maxHeight: maxHeight,
      minWidth: double.infinity,
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Padding(
          padding: effectivePadding,
          child: builder(sheetContext),
        ),
      );
    },
  );
}
