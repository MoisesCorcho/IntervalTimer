import 'package:flutter/material.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/name_format.dart';
import 'package:interval_timer/data/models/workout_exercise.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/interval_duration_picker.dart';
import 'package:interval_timer/shared/widgets/number_stepper.dart';

class ExerciseFormResult {
  const ExerciseFormResult({
    required this.name,
    required this.sets,
    required this.workSeconds,
    required this.restSeconds,
    required this.restAfterExerciseSeconds,
  });

  final String name;
  final int sets;
  final int workSeconds;
  final int restSeconds;
  final int restAfterExerciseSeconds;
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
  late int _sets;
  late int _workSeconds;
  late int _restSeconds;
  late int _restAfterExerciseSeconds;

  String? _nameError;
  String? _setsError;
  String? _workError;
  String? _restError;
  String? _restAfterError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _sets = initial?.sets ?? 3;
    _workSeconds = initial?.workSeconds ?? 40;
    _restSeconds = initial?.restSeconds ?? 20;
    _restAfterExerciseSeconds = initial?.restAfterExerciseSeconds ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool validate() {
    final nameError =
        WorkoutValidators.validateExerciseName(_nameController.text);
    final setsError = WorkoutValidators.validateSets(_sets);
    final workError = WorkoutValidators.validateWorkSeconds(_workSeconds);
    final restError = WorkoutValidators.validateRestSeconds(_restSeconds);
    final restAfterError = WorkoutValidators.validateRestAfterExerciseSeconds(
      _restAfterExerciseSeconds,
    );

    setState(() {
      _nameError = nameError;
      _setsError = setsError;
      _workError = workError;
      _restError = restError;
      _restAfterError = restAfterError;
    });

    return nameError == null &&
        setsError == null &&
        workError == null &&
        restError == null &&
        restAfterError == null;
  }

  void submit() {
    if (!validate()) return;

    widget.onSubmit(
      ExerciseFormResult(
        name: formatDisplayName(_nameController.text),
        sets: _sets,
        workSeconds: _workSeconds,
        restSeconds: _restSeconds,
        restAfterExerciseSeconds: _restAfterExerciseSeconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('exercise_name_field'),
            controller: _nameController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: l10n.exerciseName,
              errorText: _nameError,
            ),
            maxLength: WorkoutValidators.maxExerciseNameLength + 1,
            onChanged: (_) {
              if (_nameError != null) validate();
            },
          ),
          const SizedBox(height: AppTheme.spacingLg),
          NumberStepper(
            key: const Key('exercise_sets_stepper'),
            keyPrefix: 'exercise_sets_',
            value: _sets,
            min: WorkoutValidators.minSets,
            max: WorkoutValidators.maxSets,
            label: l10n.sets,
            semanticsLabel: l10n.sets,
            onChanged: (value) => setState(() {
              _sets = value;
              if (_setsError != null) validate();
            }),
          ),
          if (_setsError != null)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingXs),
              child: Text(
                _setsError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          const SizedBox(height: AppTheme.spacingLg),
          IntervalDurationPicker(
            key: const Key('exercise_work_stepper'),
            keyPrefix: 'exercise_work_',
            totalSeconds: _workSeconds,
            minSeconds: WorkoutValidators.minWorkSeconds,
            maxSeconds: WorkoutValidators.maxWorkSeconds,
            label: l10n.workDuration,
            onChanged: (value) => setState(() {
              _workSeconds = value;
              if (_workError != null) validate();
            }),
          ),
          if (_workError != null)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingXs),
              child: Text(
                _workError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          const SizedBox(height: AppTheme.spacingLg),
          IntervalDurationPicker(
            key: const Key('exercise_rest_stepper'),
            keyPrefix: 'exercise_rest_',
            totalSeconds: _restSeconds,
            minSeconds: 0,
            maxSeconds: WorkoutValidators.maxRestSeconds,
            label: l10n.restBetweenSetsDuration,
            onChanged: (value) => setState(() {
              _restSeconds = value;
              if (_restError != null) validate();
            }),
          ),
          if (_restError != null)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingXs),
              child: Text(
                _restError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          const SizedBox(height: AppTheme.spacingLg),
          IntervalDurationPicker(
            key: const Key('exercise_rest_after_stepper'),
            keyPrefix: 'exercise_rest_after_',
            totalSeconds: _restAfterExerciseSeconds,
            minSeconds: 0,
            maxSeconds: WorkoutValidators.maxRestSeconds,
            label: l10n.restAfterExerciseDuration,
            onChanged: (value) => setState(() {
              _restAfterExerciseSeconds = value;
              if (_restAfterError != null) validate();
            }),
          ),
          if (_restAfterError != null)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingXs),
              child: Text(
                _restAfterError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          const SizedBox(height: AppTheme.spacingLg),
          AppPrimaryButton(
            key: const Key('exercise_save_button'),
            onPressed: submit,
            label: l10n.save,
            expand: true,
          ),
        ],
      ),
    );
  }
}
