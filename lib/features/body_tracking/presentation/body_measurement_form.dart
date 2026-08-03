import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/local_date_format.dart';
import 'package:interval_timer/features/body_tracking/application/body_tracking_providers.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/dialog_actions_row.dart';

/// Opens bottom sheet to create or edit a body measurement (F15 R3, R6, R9–R11).
Future<bool?> showBodyMeasurementForm({
  required BuildContext context,
  BodyMeasurement? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => BodyMeasurementFormSheet(existing: existing),
  );
}

class BodyMeasurementFormSheet extends ConsumerStatefulWidget {
  const BodyMeasurementFormSheet({super.key, this.existing});

  final BodyMeasurement? existing;

  @override
  ConsumerState<BodyMeasurementFormSheet> createState() =>
      _BodyMeasurementFormSheetState();
}

class _BodyMeasurementFormSheetState
    extends ConsumerState<BodyMeasurementFormSheet> {
  late final TextEditingController _weightController;
  late final TextEditingController _waistController;
  late final TextEditingController _armController;
  late final TextEditingController _legController;
  late DateTime _selectedDate;
  String? _weightError;
  String? _waistError;
  String? _armError;
  String? _legError;
  String? _dateError;
  bool _saving = false;
  bool _measuresExpanded = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final now = DateTime.now();
    _selectedDate = existing != null
        ? LocalDateFormat.parse(existing.localDate)
        : DateTime(now.year, now.month, now.day);

    final unit = ref.read(bodyWeightUnitProvider).valueOrNull ??
        BodyWeightUnit.kg;
    if (existing != null) {
      final display = BodyWeightUnit.fromKg(existing.weightKg, unit);
      _weightController =
          TextEditingController(text: display.toStringAsFixed(1));
      _waistController = TextEditingController(
        text: existing.waistCm?.toStringAsFixed(1) ?? '',
      );
      _armController = TextEditingController(
        text: existing.armCm?.toStringAsFixed(1) ?? '',
      );
      _legController = TextEditingController(
        text: existing.legCm?.toStringAsFixed(1) ?? '',
      );
      _measuresExpanded = existing.waistCm != null ||
          existing.armCm != null ||
          existing.legCm != null;
    } else {
      _weightController = TextEditingController();
      _waistController = TextEditingController();
      _armController = TextEditingController();
      _legController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _armController.dispose();
    _legController.dispose();
    super.dispose();
  }

  double? _parseOptional(String raw) {
    final t = raw.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  String? _messageForCode(String? code) {
    return switch (code) {
      'weight_required' || 'weight_invalid' =>
        UiStrings.bodyWeightValidationRequired,
      'weight_range' => UiStrings.bodyWeightValidationRange,
      'measure_invalid' || 'measure_range' =>
        UiStrings.bodyWeightValidationMeasure,
      'date_future' => UiStrings.bodyWeightValidationDateFuture,
      'date_invalid' => UiStrings.bodyWeightValidationDateInvalid,
      _ => null,
    };
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(today) ? today : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _save() async {
    final unit = ref.read(bodyWeightUnitProvider).valueOrNull ??
        BodyWeightUnit.kg;
    final weightRaw = _parseOptional(_weightController.text);
    final weightKg = weightRaw == null
        ? null
        : BodyWeightUnit.toKg(weightRaw, unit);
    final waist = _parseOptional(_waistController.text);
    final arm = _parseOptional(_armController.text);
    final leg = _parseOptional(_legController.text);
    final localDate = LocalDateFormat.fromDateTime(_selectedDate);

    final weightCode = BodyMeasurementValidation.validateWeightKg(weightKg);
    final waistCode = BodyMeasurementValidation.validateMeasureCm(waist);
    final armCode = BodyMeasurementValidation.validateMeasureCm(arm);
    final legCode = BodyMeasurementValidation.validateMeasureCm(leg);
    final dateCode =
        BodyMeasurementValidation.validateLocalDate(localDate);

    setState(() {
      _weightError = _messageForCode(weightCode);
      _waistError = _messageForCode(waistCode);
      _armError = _messageForCode(armCode);
      _legError = _messageForCode(legCode);
      _dateError = _messageForCode(dateCode);
    });

    if (weightCode != null ||
        waistCode != null ||
        armCode != null ||
        legCode != null ||
        dateCode != null) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(bodyMeasurementControllerProvider).save(
            localDate: localDate,
            weightKg: weightKg!,
            waistCm: waist,
            armCm: arm,
            legCm: leg,
            existingId: widget.existing?.id,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UiStrings.persistenceError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = ref.watch(bodyWeightUnitProvider).valueOrNull ??
        BodyWeightUnit.kg;
    final unitLabel = unit == BodyWeightUnit.kg
        ? UiStrings.bodyWeightUnitKg
        : UiStrings.bodyWeightUnitLb;
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        key: const Key('body_measurement_form'),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null
                  ? UiStrings.bodyWeightFormTitle
                  : UiStrings.bodyWeightFormEditTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ListTile(
              key: const Key('body_weight_date_field'),
              contentPadding: EdgeInsets.zero,
              title: const Text(UiStrings.bodyWeightDateLabel),
              subtitle: Text(LocalDateFormat.fromDateTime(_selectedDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
              minVerticalPadding: 12,
            ),
            if (_dateError != null)
              Text(
                _dateError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            const SizedBox(height: AppTheme.spacingSm),
            TextField(
              key: const Key('body_weight_input'),
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: '${UiStrings.bodyWeightFieldLabel} ($unitLabel)',
                errorText: _weightError,
              ),
              onChanged: (_) {
                if (_weightError != null) {
                  setState(() => _weightError = null);
                }
              },
            ),
            const SizedBox(height: AppTheme.spacingSm),
            ExpansionTile(
              key: const Key('body_weight_measures_tile'),
              initiallyExpanded: _measuresExpanded,
              title: const Text(UiStrings.bodyWeightMeasuresOptional),
              onExpansionChanged: (v) => setState(() => _measuresExpanded = v),
              children: [
                TextField(
                  key: const Key('body_weight_waist_input'),
                  controller: _waistController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: UiStrings.bodyWeightWaistLabel,
                    errorText: _waistError,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                TextField(
                  key: const Key('body_weight_arm_input'),
                  controller: _armController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: UiStrings.bodyWeightArmLabel,
                    errorText: _armError,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                TextField(
                  key: const Key('body_weight_leg_input'),
                  controller: _legController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: UiStrings.bodyWeightLegLabel,
                    errorText: _legError,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            DialogActionsRow(
              children: [
                AppSecondaryButton(
                  onPressed: _saving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  label: UiStrings.cancel,
                ),
                AppPrimaryButton(
                  key: const Key('body_weight_save_button'),
                  onPressed: _saving ? null : _save,
                  label: UiStrings.save,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
          ],
        ),
      ),
    );
  }
}
