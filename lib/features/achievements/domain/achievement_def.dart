import 'package:flutter/material.dart';

/// Metric used to evaluate an achievement threshold (F13 R5).
enum AchievementMetricKind {
  completedSessionCount,
  currentStreakDays,
  completedTotalMinutes,
}

/// Static catalog entry — not persisted (F13 design).
class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.icon,
    required this.kind,
    required this.threshold,
  });

  final String id;
  final IconData icon;
  final AchievementMetricKind kind;
  final int threshold;
}
