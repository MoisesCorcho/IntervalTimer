import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// Subtle horizontal rule between major History blocks (progress / weight /
/// calendar / sessions). Spacing + hairline — not a heavy card border.
class HistorySectionDivider extends StatelessWidget {
  const HistorySectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      key: const Key('history_section_divider'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: scheme.outlineVariant.withValues(alpha: 0.55),
      ),
    );
  }
}
