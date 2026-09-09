import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/body_tracking/application/body_tracking_providers.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_measurement_form.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';

/// Full weight history in a modal bottom sheet (F15 R6) — keeps Historial compact.
Future<void> showBodyWeightHistorySheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => const BodyWeightHistorySheet(),
  );
}

class BodyWeightHistorySheet extends ConsumerWidget {
  const BodyWeightHistorySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(bodyMeasurementsProvider);
    final unit = ref.watch(bodyWeightUnitProvider).valueOrNull ??
        BodyWeightUnit.kg;
    final theme = Theme.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.72;

    return SizedBox(
      key: const Key('body_weight_history_sheet'),
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMd,
              AppTheme.spacingSm,
              AppTheme.spacingMd,
              AppTheme.spacingSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.bodyWeightHistorySheetTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  key: const Key('body_weight_sheet_add'),
                  onPressed: () => _openForm(context, ref),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(context.l10n.bodyWeightRegisterButton),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: measurementsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.l10n.bodyWeightErrorRetry),
                      const SizedBox(height: AppTheme.spacingSm),
                      AppPrimaryButton(
                        onPressed: () =>
                            ref.invalidate(bodyMeasurementsProvider),
                        label: context.l10n.retry,
                      ),
                    ],
                  ),
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Text(
                        context.l10n.bodyWeightEmptyMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                // Newest first for browsing / edit / delete.
                final ordered = list.reversed.toList();
                return ListView.separated(
                  key: const Key('body_weight_history_list'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  itemCount: ordered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final m = ordered[index];
                    return _MeasurementTile(
                      measurement: m,
                      unit: unit,
                      onEdit: () => _openForm(context, ref, existing: m),
                      onDelete: () => _confirmDelete(context, ref, m),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BodyMeasurement measurement,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('body_weight_delete_dialog'),
        title: Text(context.l10n.bodyWeightDeleteTitle),
        content: Text(context.l10n.bodyWeightDeleteMessage),
        actions: [
          DialogActionsRow(
            children: [
              AppSecondaryButton(
                compact: true,
                onPressed: () => Navigator.pop(context, false),
                label: context.l10n.cancel,
              ),
              AppPrimaryButton(
                key: const Key('body_weight_delete_confirm'),
                compact: true,
                onPressed: () => Navigator.pop(context, true),
                label: context.l10n.delete,
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
        SnackBar(content: Text(context.l10n.bodyWeightDeleted)),
      );
      final remaining =
          await ref.read(bodyMeasurementRepositoryProvider).getAll();
      if (remaining.isEmpty && context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.persistenceError)),
      );
    }
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
    final value = BodyWeightUnit.formatDisplay(measurement.weightKg, unit);
    final unitLabel = unit == BodyWeightUnit.kg
        ? context.l10n.bodyWeightUnitKg
        : context.l10n.bodyWeightUnitLb;

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
            tooltip: context.l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            constraints: const BoxConstraints(
              minWidth: AppTheme.buttonMinHeight,
              minHeight: AppTheme.buttonMinHeight,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            key: Key('body_weight_delete_${measurement.id}'),
            tooltip: context.l10n.delete,
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
