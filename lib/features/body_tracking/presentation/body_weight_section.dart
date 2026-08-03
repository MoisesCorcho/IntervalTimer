import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/body_tracking/application/body_tracking_providers.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_measurement_form.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_weight_line_chart.dart';
import 'package:interval_timer/features/stats/application/stats_providers.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';

/// Body weight block embedded in History (F15 R2, R5, R6, R12).
///
/// Placement: after F12 progress, before calendar.
class BodyWeightSection extends ConsumerWidget {
  const BodyWeightSection({super.key});

  static const _recentLimit = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  UiStrings.bodyWeightSectionTitle,
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
                      ? UiStrings.bodyWeightRegisterCta
                      : UiStrings.bodyWeightUpdateCta,
                ),
              ),
            ],
          ),
          Text(
            key: const Key('body_weight_caption'),
            _captionText(weightReading.weightKg, weightReading.isEstimated, unit),
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
              final recent = list.reversed.take(_recentLimit).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BodyWeightLineChart(
                    measurements: list,
                    unit: unit,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    UiStrings.bodyWeightRecentTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  for (final m in recent)
                    _MeasurementTile(
                      measurement: m,
                      unit: unit,
                      onEdit: () => _openForm(context, ref, existing: m),
                      onDelete: () => _confirmDelete(context, ref, m),
                    ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('body_weight_add_another'),
                      onPressed: () => _openForm(context, ref),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(UiStrings.bodyWeightRegisterButton),
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
    double weightKg,
    bool estimated,
    BodyWeightUnit unit,
  ) {
    final value = BodyWeightUnit.formatDisplay(weightKg, unit);
    final unitLabel =
        unit == BodyWeightUnit.kg ? UiStrings.bodyWeightUnitKg : UiStrings.bodyWeightUnitLb;
    if (estimated) {
      return UiStrings.bodyWeightCaptionEstimated
          .replaceAll('{value}', value)
          .replaceAll('{unit}', unitLabel);
    }
    return UiStrings.bodyWeightCaptionRegistered
        .replaceAll('{value}', value)
        .replaceAll('{valueUnit}', unitLabel);
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
        const SnackBar(content: Text(UiStrings.bodyWeightSaved)),
      );
    }
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BodyMeasurement measurement,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('body_weight_delete_dialog'),
        title: const Text(UiStrings.bodyWeightDeleteTitle),
        content: const Text(UiStrings.bodyWeightDeleteMessage),
        actions: [
          DialogActionsRow(
            children: [
              AppSecondaryButton(
                compact: true,
                onPressed: () => Navigator.pop(context, false),
                label: UiStrings.cancel,
              ),
              AppPrimaryButton(
                key: const Key('body_weight_delete_confirm'),
                compact: true,
                onPressed: () => Navigator.pop(context, true),
                label: UiStrings.delete,
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(bodyMeasurementControllerProvider).delete(measurement.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UiStrings.bodyWeightDeleted)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UiStrings.persistenceError)),
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
    return Card(
      key: const Key('body_weight_empty'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            Text(
              UiStrings.bodyWeightEmptyMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            AppPrimaryButton(
              key: const Key('body_weight_empty_cta'),
              onPressed: onRegister,
              label: UiStrings.bodyWeightRegisterButton,
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
    return Card(
      key: const Key('body_weight_error'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            const Text(UiStrings.bodyWeightErrorRetry),
            const SizedBox(height: AppTheme.spacingSm),
            AppPrimaryButton(
              onPressed: onRetry,
              label: UiStrings.retry,
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({
    required this.measurement,
    required this.unit,
    required this.onEdit,
    required this.onDelete,
  });

  final BodyMeasurement measurement;
  final BodyWeightUnit unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final value =
        BodyWeightUnit.formatDisplay(measurement.weightKg, unit);
    final unitLabel = unit == BodyWeightUnit.kg
        ? UiStrings.bodyWeightUnitKg
        : UiStrings.bodyWeightUnitLb;

    return ListTile(
      key: Key('body_weight_tile_${measurement.id}'),
      contentPadding: EdgeInsets.zero,
      title: Text('${measurement.localDate} · $value $unitLabel'),
      subtitle: _measuresSubtitle(measurement),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('body_weight_edit_${measurement.id}'),
            tooltip: UiStrings.edit,
            icon: const Icon(Icons.edit_outlined),
            constraints: const BoxConstraints(
              minWidth: AppTheme.buttonMinHeight,
              minHeight: AppTheme.buttonMinHeight,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            key: Key('body_weight_delete_${measurement.id}'),
            tooltip: UiStrings.delete,
            icon: const Icon(Icons.delete_outline),
            constraints: const BoxConstraints(
              minWidth: AppTheme.buttonMinHeight,
              minHeight: AppTheme.buttonMinHeight,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget? _measuresSubtitle(BodyMeasurement m) {
    final parts = <String>[];
    if (m.waistCm != null) {
      parts.add('Cintura ${m.waistCm!.toStringAsFixed(0)} cm');
    }
    if (m.armCm != null) {
      parts.add('Brazo ${m.armCm!.toStringAsFixed(0)} cm');
    }
    if (m.legCm != null) {
      parts.add('Pierna ${m.legCm!.toStringAsFixed(0)} cm');
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' · '));
  }
}
