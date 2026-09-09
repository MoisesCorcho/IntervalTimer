import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/body_tracking/application/body_tracking_providers.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_measurement_form.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_weight_history_sheet.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_weight_line_chart.dart';
import 'package:interval_timer/features/stats/application/stats_providers.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';

/// Compact body weight block in History (F15 R2, R5, R12).
///
/// Full measurement list lives in [showBodyWeightHistorySheet] (not inline).
class BodyWeightSection extends ConsumerWidget {
  const BodyWeightSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final measurementsAsync = ref.watch(bodyMeasurementsProvider);
    final unit = ref.watch(bodyWeightUnitProvider).valueOrNull ??
        BodyWeightUnit.kg;
    final weightReading = ref.watch(userWeightKgProvider);
    final theme = Theme.of(context);
    final captionStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Padding(
      key: const Key('body_weight_section'),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.bodyWeightSectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                key: const Key('body_weight_header_cta'),
                onPressed: () => _openForm(context, ref),
                child: Text(
                  weightReading.isEstimated
                      ? l10n.bodyWeightRegisterCta
                      : l10n.bodyWeightUpdateCta,
                ),
              ),
            ],
          ),
          Text(
            key: const Key('body_weight_caption'),
            _captionText(context, weightReading.weightKg, weightReading.isEstimated, unit),
            style: captionStyle,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          measurementsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              child: Center(
                child: SizedBox(
                  key: Key('body_weight_loading'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, _) => _BodyWeightError(
              onRetry: () => ref.invalidate(bodyMeasurementsProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return _EmptyBodyWeight(
                  onRegister: () => _openForm(context, ref),
                );
              }
              final latest = list.last; // watchAll is asc by localDate
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BodyWeightLineChart(
                    measurements: list,
                    unit: unit,
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  InkWell(
                    key: const Key('body_weight_last_line'),
                    onTap: () => showBodyWeightHistorySheet(context: context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingSm,
                      ),
                      child: Text(
                        _lastLineText(context, latest, unit),
                        style: captionStyle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const Key('body_weight_view_records'),
                      onPressed: () =>
                          showBodyWeightHistorySheet(context: context),
                      child: Text(
                        l10n.bodyWeightViewRecordsCount(list.length),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
        ],
      ),
    );
  }

  static String _captionText(
    BuildContext context,
    double weightKg,
    bool estimated,
    BodyWeightUnit unit,
  ) {
    final l10n = context.l10n;
    final value = BodyWeightUnit.formatDisplay(weightKg, unit);
    final unitLabel = unit == BodyWeightUnit.kg
        ? l10n.bodyWeightUnitKg
        : l10n.bodyWeightUnitLb;
    if (estimated) {
      return l10n.bodyWeightCaptionEstimated(value, unitLabel);
    }
    return l10n.bodyWeightCaptionRegistered(value, unitLabel);
  }

  static String _lastLineText(BuildContext context, BodyMeasurement m, BodyWeightUnit unit) {
    final l10n = context.l10n;
    final value = BodyWeightUnit.formatDisplay(m.weightKg, unit);
    final unitLabel = unit == BodyWeightUnit.kg
        ? l10n.bodyWeightUnitKg
        : l10n.bodyWeightUnitLb;
    return l10n.bodyWeightLastLine(value, unitLabel, m.localDate);
  }

  static Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    BodyMeasurement? existing,
  }) async {
    final saved = await showBodyMeasurementForm(
      context: context,
      existing: existing,
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.bodyWeightSaved)),
      );
    }
  }
}

class _EmptyBodyWeight extends StatelessWidget {
  const _EmptyBodyWeight({required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      key: const Key('body_weight_empty'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            Text(
              l10n.bodyWeightEmptyMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            AppPrimaryButton(
              key: const Key('body_weight_empty_cta'),
              onPressed: onRegister,
              label: l10n.bodyWeightRegisterButton,
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyWeightError extends StatelessWidget {
  const _BodyWeightError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      key: const Key('body_weight_error'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            Text(l10n.bodyWeightErrorRetry),
            const SizedBox(height: AppTheme.spacingSm),
            AppPrimaryButton(
              onPressed: onRetry,
              label: l10n.retry,
            ),
          ],
        ),
      ),
    );
  }
}
