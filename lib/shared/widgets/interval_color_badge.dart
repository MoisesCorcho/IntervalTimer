import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/contrast_text_color.dart';

class IntervalColorBadge extends StatelessWidget {
  const IntervalColorBadge({
    super.key,
    required this.name,
    required this.color,
    this.durationLabel,
  });

  final String name;
  final Color color;
  final String? durationLabel;

  @override
  Widget build(BuildContext context) {
    final textColor = contrastTextColor(color);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (durationLabel != null) ...[
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              durationLabel!,
              style: TextStyle(color: textColor.withValues(alpha: 0.9)),
            ),
          ],
        ],
      ),
    );
  }
}