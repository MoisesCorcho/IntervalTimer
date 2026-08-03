import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/stats/application/stats_providers.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';
import 'package:interval_timer/features/stats/presentation/activity_bar_chart.dart';
import 'package:interval_timer/features/stats/presentation/chart_period_toggle.dart';

/// Progress block for History: metrics + chart (F12 R1–R4, R9–R12).
class ProgressSummarySection extends ConsumerWidget {
  const ProgressSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(statsSummaryProvider);
    final chartAsync = ref.watch(activityChartProvider);
    final period = ref.watch(chartPeriodProvider);
    final metLabel = _formatMet(kDefaultMet);

    return Padding(
      key: const Key('progress_summary_section'),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: summaryAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          child: Center(
            child: SizedBox(
              key: Key('progress_stats_loading'),
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (_, _) => _StatsError(
          onRetry: () {
            ref.invalidate(sessionLogsForStatsProvider);
          },
        ),
        data: (summary) {
          final captionStyle =
              Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      UiStrings.progressSectionTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    key: const Key('progress_kcal_info'),
                    tooltip: UiStrings.progressKcalInfoTooltip,
                    icon: const Icon(Icons.info_outline, size: 20),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: AppTheme.buttonMinHeight,
                      minHeight: AppTheme.buttonMinHeight,
                    ),
                    onPressed: () => _showKcalInfoDialog(context, metLabel),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSm),
              // 2×2 metric grid (F12 presentation polish)
              Column(
                key: const Key('stat_metrics_grid'),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatMetricCard(
                          key: const Key('stat_metric_streak'),
                          value: '${summary.currentStreakDays}',
                          label: UiStrings.progressStreakLabel,
                          icon: Icons.local_fire_department_rounded,
                          accent: AppTheme.warmupColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: StatMetricCard(
                          key: const Key('stat_metric_week_minutes'),
                          value: '${summary.weekMinutes}',
                          label: UiStrings.progressWeekMinutesLabel,
                          icon: Icons.timer_rounded,
                          accent: AppTheme.restColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    children: [
                      Expanded(
                        child: StatMetricCard(
                          key: const Key('stat_metric_month_sessions'),
                          value: '${summary.monthSessionCount}',
                          label: UiStrings.progressMonthSessionsLabel,
                          icon: Icons.fitness_center_rounded,
                          accent: AppTheme.workColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: StatMetricCard(
                          key: const Key('stat_metric_kcal'),
                          value: '${summary.totalEstimatedKcal}',
                          label: UiStrings.progressKcalLabel,
                          icon: Icons.bolt_rounded,
                          accent: AppTheme.stretchColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (summary.totalSessionCount > 0) ...[
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  key: const Key('progress_totals_line'),
                  UiStrings.progressTotalLine
                      .replaceAll(
                        '{totals}',
                        _formatTotalDuration(summary.totalMinutes),
                      )
                      .replaceAll(
                        '{sessions}',
                        '${summary.totalSessionCount}',
                      ),
                  style: captionStyle,
                ),
              ],
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                key: const Key('progress_kcal_method_caption'),
                UiStrings.progressKcalMethodCaption.replaceAll(
                  '{met}',
                  metLabel,
                ),
                style: captionStyle,
              ),
              const SizedBox(height: 2),
              Text(
                key: const Key('progress_weight_caption'),
                summary.isWeightEstimated
                    ? UiStrings.progressWeightEstimated.replaceAll(
                        '{kg}',
                        _formatWeight(summary.weightKgUsed),
                      )
                    : UiStrings.progressWeightRegistered.replaceAll(
                        '{kg}',
                        _formatWeight(summary.weightKgUsed),
                      ),
                style: captionStyle,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              ChartPeriodToggle(
                value: period,
                onChanged: (p) {
                  ref.read(chartPeriodProvider.notifier).setPeriod(p);
                },
              ),
              const SizedBox(height: AppTheme.spacingSm),
              chartAsync.when(
                loading: () => const SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (series) => ActivityBarChart(
                  series: series,
                  period: period,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _showKcalInfoDialog(
    BuildContext context,
    String metLabel,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('progress_kcal_info_dialog'),
        title: const Text(UiStrings.progressKcalInfoTitle),
        content: SingleChildScrollView(
          child: Text(
            UiStrings.progressKcalInfoBody.replaceAll('{met}', metLabel),
          ),
        ),
        actions: [
          TextButton(
            key: const Key('progress_kcal_info_close'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(UiStrings.progressKcalInfoClose),
          ),
        ],
      ),
    );
  }

  static String _formatTotalDuration(int totalMinutes) {
    if (totalMinutes >= 60) {
      final h = totalMinutes ~/ 60;
      final rem = totalMinutes % 60;
      if (rem == 0) return '$h h';
      return '$h h $rem min';
    }
    return '$totalMinutes min';
  }

  static String _formatWeight(double kg) {
    if (kg == kg.roundToDouble()) return kg.toInt().toString();
    return kg.toStringAsFixed(1);
  }

  /// Locale-neutral MET label for Spanish UI (comma decimal).
  static String _formatMet(double met) {
    if (met == met.roundToDouble()) return met.toInt().toString();
    return met.toStringAsFixed(1).replaceAll('.', ',');
  }
}

/// Stylized metric tile: tinted gradient, icon bubble, value hierarchy.
///
/// Used in the History progress 2×2 grid (F12 R2).
class StatMetricCard extends StatelessWidget {
  const StatMetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tintStrong = Color.alphaBlend(
      accent.withValues(alpha: 0.14),
      scheme.surface,
    );
    final tintSoft = Color.alphaBlend(
      accent.withValues(alpha: 0.05),
      scheme.surface,
    );
    final bubbleFill = accent.withValues(alpha: 0.18);
    final borderColor = accent.withValues(alpha: 0.22);

    return Semantics(
      label: '$value, $label',
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tintStrong, tintSoft],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingSm + 2,
            AppTheme.spacingMd,
            AppTheme.spacingSm + 2,
          ),
          // Info (value + label) top-left; icon top-right — opposite corners.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                        height: 1.1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: bubbleFill,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  child: Icon(
                    icon,
                    size: 20,
                    color: accent,
                    semanticLabel: label,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const Key('progress_stats_error'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            Text(
              UiStrings.progressStatsError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            TextButton(
              key: const Key('progress_stats_retry'),
              onPressed: onRetry,
              child: const Text(UiStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
