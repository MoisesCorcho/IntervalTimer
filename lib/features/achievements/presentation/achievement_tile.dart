import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/local_date_format.dart';
import 'package:interval_timer/features/achievements/domain/achievement_def.dart';
import 'package:interval_timer/features/achievements/domain/achievement_progress_view.dart';

/// Single achievement row for the collection list (F13 R3, R12).
class AchievementTile extends StatelessWidget {
  const AchievementTile({
    super.key,
    required this.progress,
  });

  final AchievementProgressView progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final def = progress.def;
    final unlocked = progress.isUnlocked;
    final muted = theme.colorScheme.onSurfaceVariant;
    final titleColor = unlocked
        ? theme.colorScheme.onSurface
        : muted;
    final iconColor = unlocked
        ? theme.colorScheme.primary
        : muted.withValues(alpha: 0.55);

    return Semantics(
      label: '${UiStrings.achievementTitle(def.id)}. '
          '${unlocked ? UiStrings.achievementsUnlockedBadge : UiStrings.achievementsLockedBadge}',
      child: Padding(
        key: Key('achievement_tile_${def.id}'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppTheme.buttonMinHeight,
              height: AppTheme.buttonMinHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: unlocked
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                def.icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    UiStrings.achievementTitle(def.id),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    UiStrings.achievementDescription(def.id),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  if (unlocked && progress.unlockedAt != null)
                    Text(
                      UiStrings.achievementsUnlockedOn.replaceAll(
                        '{date}',
                        _formatDate(progress.unlockedAt!),
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress.progressFraction,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _progressLabel(def, progress.current, progress.target),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unlocked)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              )
            else
              Icon(
                Icons.lock_outline_rounded,
                color: muted.withValues(alpha: 0.7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  static String _progressLabel(AchievementDef def, int current, int target) {
    final template = switch (def.kind) {
      AchievementMetricKind.completedSessionCount =>
        UiStrings.achievementsProgressSessions,
      AchievementMetricKind.currentStreakDays =>
        UiStrings.achievementsProgressDays,
      AchievementMetricKind.completedTotalMinutes =>
        UiStrings.achievementsProgressMinutes,
    };
    return template
        .replaceAll('{current}', '$current')
        .replaceAll('{target}', '$target');
  }

  static String _formatDate(DateTime utc) {
    final local = utc.toLocal();
    return LocalDateFormat.fromDateTime(local);
  }
}
