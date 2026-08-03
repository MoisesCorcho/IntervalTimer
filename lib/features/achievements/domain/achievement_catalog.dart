import 'package:flutter/material.dart';
import 'package:interval_timer/features/achievements/domain/achievement_def.dart';

/// Static catalog of at least 12 achievements (F13 R1).
const List<AchievementDef> kAchievementCatalog = [
  AchievementDef(
    id: 'first_session',
    icon: Icons.flag_rounded,
    kind: AchievementMetricKind.completedSessionCount,
    threshold: 1,
  ),
  AchievementDef(
    id: 'sessions_10',
    icon: Icons.fitness_center_rounded,
    kind: AchievementMetricKind.completedSessionCount,
    threshold: 10,
  ),
  AchievementDef(
    id: 'sessions_25',
    icon: Icons.fitness_center_rounded,
    kind: AchievementMetricKind.completedSessionCount,
    threshold: 25,
  ),
  AchievementDef(
    id: 'sessions_50',
    icon: Icons.emoji_events_rounded,
    kind: AchievementMetricKind.completedSessionCount,
    threshold: 50,
  ),
  AchievementDef(
    id: 'sessions_100',
    icon: Icons.workspace_premium_rounded,
    kind: AchievementMetricKind.completedSessionCount,
    threshold: 100,
  ),
  AchievementDef(
    id: 'streak_3',
    icon: Icons.local_fire_department_rounded,
    kind: AchievementMetricKind.currentStreakDays,
    threshold: 3,
  ),
  AchievementDef(
    id: 'streak_7',
    icon: Icons.local_fire_department_rounded,
    kind: AchievementMetricKind.currentStreakDays,
    threshold: 7,
  ),
  AchievementDef(
    id: 'streak_14',
    icon: Icons.whatshot_rounded,
    kind: AchievementMetricKind.currentStreakDays,
    threshold: 14,
  ),
  AchievementDef(
    id: 'streak_30',
    icon: Icons.whatshot_rounded,
    kind: AchievementMetricKind.currentStreakDays,
    threshold: 30,
  ),
  AchievementDef(
    id: 'minutes_60',
    icon: Icons.timer_rounded,
    kind: AchievementMetricKind.completedTotalMinutes,
    threshold: 60,
  ),
  AchievementDef(
    id: 'minutes_300',
    icon: Icons.timer_rounded,
    kind: AchievementMetricKind.completedTotalMinutes,
    threshold: 300,
  ),
  AchievementDef(
    id: 'minutes_1000',
    icon: Icons.hourglass_top_rounded,
    kind: AchievementMetricKind.completedTotalMinutes,
    threshold: 1000,
  ),
];
