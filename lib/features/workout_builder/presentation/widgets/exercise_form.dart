import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/duration_parser.dart';
import 'package:interval_timer/data/models/workout_exercise.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';

class ExerciseFormResult {
  const ExerciseFormResult({
    required this.name,
    required this.sets,
    required this.workSeconds,
    required this.restSeconds,
  });

  final String name;
  final int sets;
  final int workSeconds;
  final int restSeconds;
}

class ExerciseForm extends StatefulWidget {
  const ExerciseForm({
    super.key,
    this.initial,
    required this.onSubmit,
  });

  final WorkoutExercise? initial;
  final ValueChanged<ExerciseFormResult> onSubmit;

  @override
  State<ExerciseForm> createState() => ExerciseFormState();
}

class ExerciseFormState extends State<ExerciseForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _setsController;
  late final TextEditingController _workController;
  late final TextEditingController _restController;

  String? _nameError;
  String? _setsError;
  String? _workError;
  String? _restError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _setsController = TextEditingController(
      text: initial?.sets.toString() ?? '3',
    );
    _workController = TextEditingController(
      text: initial != null
          ? formatDurationMmSs(initial.workSeconds)
          : '00:40',
    );
    _restController = TextEditingController(
      text: initial != null
          ? formatDurationMmSs(initial.restSeconds)
          : '00:20',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _workController.dispose();
    _restController.dispose();
    super.dispose();
  }

  bool validate() {
    final nameError =
        WorkoutValidators.validateExerciseName(_nameController.text);
    final sets = int.tryParse(_setsController.text.trim());
    final setsError = WorkoutValidators.validateSets(sets);
    final workSeconds = parseDurationMmSs(_workController.text);
    final workError = WorkoutValidators.validateWorkSeconds(workSeconds);
    final restSeconds =
        parseDurationMmSs(_restController.text, allowZero: true);
    final restError = WorkoutValidators.validateRestSeconds(restSeconds);

    setState(() {
      _nameError = nameError;
      _setsError = setsError;
      _workError = workError;
      _restError = restError;
    });

    return nameError == null &&
        setsError == null &&
        workError == null &&
        restError == null;
  }

  void submit() {
    if (!validate()) return;

    widget.onSubmit(
      ExerciseFormResult(
        name: _nameController.text.trim(),
        sets: int.parse(_setsController.text.trim()),
        workSeconds: parseDurationMmSs(_workController.text)!,
        restSeconds:
            parseDurationMmSs(_restController.text, allowZero: true)!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('exercise_name_field'),
          controller: _nameController,
          decoration: InputDecoration(
            labelText: UiStrings.exerciseName,
            errorText: _nameError,
          ),
          maxLength: WorkoutValidators.maxExerciseNameLength + 1,
          onChanged: (_) {
            if (_nameError != null) validate();
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        TextField(
          key: const Key('exercise_sets_field'),
          controller: _setsController,
          decoration: InputDecoration(
            labelText: UiStrings.sets,
            errorText: _setsError,
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) {
            if (_setsError != null) validate();
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        TextField(
          key: const Key('exercise_work_field'),
          controller: _workController,
          decoration: InputDecoration(
            labelText: UiStrings.workDuration,
            errorText: _workError,
          ),
          keyboardType: TextInputType.datetime,
          onChanged: (_) {
            if (_workError != null) validate();
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        TextField(
          key: const Key('exercise_rest_field'),
          controller: _restController,
          decoration: InputDecoration(
            labelText: UiStrings.restDuration,
            errorText: _restError,
          ),
          keyboardType: TextInputType.datetime,
          onChanged: (_) {
            if (_restError != null) validate();
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        FilledButton(
          key: const Key('exercise_save_button'),
          onPressed: submit,
          child: const Text(UiStrings.save),
        ),
      ],
    );
  }
}