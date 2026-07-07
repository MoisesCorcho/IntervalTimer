import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/duration_parser.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';

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
  late final TextEditingController _durationController;
  late Color _selectedColor;
  late IntervalType _selectedType;

  String? _nameError;
  String? _durationError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _durationController = TextEditingController(
      text: initial != null
          ? formatDurationMmSs(initial.durationSeconds)
          : '01:00',
    );
    _selectedColor = Color(initial?.colorArgb ?? widget.defaultColorArgb);
    _selectedType = initial?.type ?? IntervalType.work;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  bool validate() {
    final name = _nameController.text.trim();
    String? nameError;
    String? durationError;

    if (name.isEmpty) {
      nameError = UiStrings.nameRequired;
    } else if (name.length > 50) {
      nameError = UiStrings.nameTooLong;
    }

    final duration = parseDurationMmSs(_durationController.text);
    if (duration == null) {
      durationError = UiStrings.durationInvalid;
    }

    setState(() {
      _nameError = nameError;
      _durationError = durationError;
    });

    return nameError == null && durationError == null;
  }

  void submit() {
    if (!validate()) return;

    widget.onSubmit(
      IntervalFormResult(
        name: _nameController.text.trim(),
        durationSeconds: parseDurationMmSs(_durationController.text)!,
        colorArgb: _selectedColor.toARGB32(),
        type: _selectedType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('interval_name_field'),
          controller: _nameController,
          decoration: InputDecoration(
            labelText: UiStrings.intervalName,
            errorText: _nameError,
          ),
          maxLength: 51,
          onChanged: (_) {
            if (_nameError != null) validate();
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        TextField(
          key: const Key('interval_duration_field'),
          controller: _durationController,
          decoration: InputDecoration(
            labelText: UiStrings.duration,
            errorText: _durationError,
          ),
          keyboardType: TextInputType.datetime,
          onChanged: (_) {
            if (_durationError != null) validate();
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(UiStrings.color, style: Theme.of(context).textTheme.labelLarge),
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
        FilledButton(
          key: const Key('interval_save_button'),
          onPressed: submit,
          child: const Text(UiStrings.save),
        ),
      ],
    );
  }
}