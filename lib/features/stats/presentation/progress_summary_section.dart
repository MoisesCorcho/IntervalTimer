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
              const SizedBox(height: AppTheme.spacingXs),
              Row(
                children: [
                  Expanded(
                    child: StatMetricCard(
                      key: const Key('stat_metric_streak'),
                      value: '${summary.currentStreakDays}',
                      label: UiStrings.progressStreakLabel,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: StatMetricCard(
                      key: const Key('stat_metric_week_minutes'),
                      value: '${summary.weekMinutes}',
                      label: UiStrings.progressWeekMinutesLabel,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: StatMetricCard(
                      key: const Key('stat_metric_month_sessions'),
                      value: '${summary.monthSessionCount}',
                      label: UiStrings.progressMonthSessionsLabel,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: StatMetricCard(
                      key: const Key('stat_metric_kcal'),
                      value: '${summary.totalEstimatedKcal}',
                      label: UiStrings.progressKcalLabel,
                    ),
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
              if (summary.isWeightEstimated) ...[
                const SizedBox(height: 2),
                Text(
                  key: const Key('progress_weight_caption'),
                  UiStrings.progressWeightEstimated.replaceAll(
                    '{kg}',
                    _formatWeight(summary.weightKgUsed),
                  ),
                  style: captionStyle,
                ),
              ],
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

/// Value + label metric card (F12 R2).
class StatMetricCard extends StatelessWidget {
  const StatMetricCard({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXs,
          vertical: AppTheme.spacingSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
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
