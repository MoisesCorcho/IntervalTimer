import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/name_format.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/interval_duration_picker.dart';


class IntervalFormResult {
  const IntervalFormResult({
    required this.name,
    required this.durationSeconds,
    required this.colorArgb,
    required this.type,
  });

  final String name;
  final int durationSeconds;
  final int colorArgb;
  final IntervalType type;
}

class IntervalForm extends StatefulWidget {
  const IntervalForm({
    super.key,
    this.initial,
    required this.onSubmit,
    required this.defaultColorArgb,
  });

  final Interval? initial;
  final ValueChanged<IntervalFormResult> onSubmit;
  final int defaultColorArgb;

  @override
  State<IntervalForm> createState() => IntervalFormState();
}

class IntervalFormState extends State<IntervalForm> {
  late final TextEditingController _nameController;
  late int _durationSeconds;
  late Color _selectedColor;
  late IntervalType _selectedType;

  String? _nameError;

  static const _minDurationSeconds = 1;
  static const _maxDurationSeconds = 5999;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _durationSeconds = initial?.durationSeconds ?? 60;
    _selectedColor = Color(initial?.colorArgb ?? widget.defaultColorArgb);
    _selectedType = initial?.type ?? IntervalType.work;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool validate() {
    final name = _nameController.text.trim();
    String? nameError;

    if (name.isEmpty) {
      nameError = UiStrings.nameRequired;
    } else if (name.length > 50) {
      nameError = UiStrings.nameTooLong;
    }

    setState(() {
      _nameError = nameError;
    });

    return nameError == null;
  }

  void submit() {
    if (!validate()) return;

    widget.onSubmit(
      IntervalFormResult(
        name: formatDisplayName(_nameController.text),
        durationSeconds: _durationSeconds,
        colorArgb: _selectedColor.toARGB32(),
        type: _selectedType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('interval_name_field'),
            controller: _nameController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: UiStrings.intervalName,
              errorText: _nameError,
            ),
            maxLength: 51,
            onChanged: (_) {
              if (_nameError != null) validate();
            },
          ),
          const SizedBox(height: AppTheme.spacingLg),
          IntervalDurationPicker(
            key: const Key('interval_duration_stepper'),
            keyPrefix: 'interval_duration_',
            totalSeconds: _durationSeconds,
            minSeconds: _minDurationSeconds,
            maxSeconds: _maxDurationSeconds,
            label: UiStrings.duration,
            onChanged: (value) => setState(() => _durationSeconds = value),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            UiStrings.color,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AppPrimaryButton(
            key: const Key('interval_save_button'),
            onPressed: submit,
            label: UiStrings.save,
            expand: true,
          ),
        ],
      ),
    );
  }
}
