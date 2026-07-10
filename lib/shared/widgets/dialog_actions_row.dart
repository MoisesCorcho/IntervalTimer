import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// Horizontal row of dialog actions (Cancel | Confirm) so buttons sit
/// side-by-side instead of stacking via [AlertDialog]'s [OverflowBar].
///
/// Pass as a **single** item in [AlertDialog.actions]:
/// ```dart
/// actions: [
///   DialogActionsRow(
///     children: [
///       AppSecondaryButton(compact: true, ...),
///       AppPrimaryButton(compact: true, ...),
///     ],
///   ),
/// ],
/// ```
class DialogActionsRow extends StatelessWidget {
  const DialogActionsRow({
    super.key,
    required this.children,
    this.spacing = AppTheme.spacingSm,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Flexible(child: children[i]),
        ],
      ],
    );
  }
}
