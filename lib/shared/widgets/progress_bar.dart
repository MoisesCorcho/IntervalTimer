import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.remainingFraction,
    required this.color,
    this.height = 8,
  });

  final double remainingFraction;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: LinearProgressIndicator(
        value: remainingFraction.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: color.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}