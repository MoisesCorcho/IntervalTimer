import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/exercise_form.dart';
import 'package:interval_timer/shared/widgets/interval_duration_picker.dart';
import 'package:interval_timer/shared/widgets/number_stepper.dart';


void main() {
  testWidgets('exercise form rejects empty name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseForm(onSubmit: (_) {}),
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('exercise_name_field')), '');
    final saveButton = find.byKey(const Key('exercise_save_button'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text(UiStrings.nameRequired), findsOneWidget);
  });

  testWidgets('shows two rest steppers; save persists both rest ints', (
    tester,
  ) async {
    ExerciseFormResult? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseForm(onSubmit: (r) => result = r),
          ),
        ),
      ),
    );

    expect(find.byType(NumberStepper), findsOneWidget);
    // work + rest between sets + rest after exercise
    expect(find.byType(IntervalDurationPicker), findsNWidgets(3));
    expect(find.text(UiStrings.restBetweenSetsDuration), findsOneWidget);
    expect(find.text(UiStrings.restAfterExerciseDuration), findsOneWidget);
    expect(find.byKey(const Key('exercise_sets_field')), findsNothing);
    expect(find.byKey(const Key('exercise_work_field')), findsNothing);
    expect(find.byKey(const Key('exercise_rest_field')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('exercise_name_field')),
      'Burpees',
    );

    // defaults: sets 3, work 40, rest 20, restAfter 0
    final setsInc =
        find.byKey(const Key('exercise_sets_number_stepper_increment'));
    await tester.ensureVisible(setsInc);
    await tester.tap(setsInc);
    await tester.pumpAndSettle();

    final workInc =
        find.byKey(const Key('exercise_work_duration_stepper_sec_increment'));
    await tester.ensureVisible(workInc);
    await tester.tap(workInc);
    await tester.pumpAndSettle();

    final restDec =
        find.byKey(const Key('exercise_rest_duration_stepper_sec_decrement'));
    await tester.ensureVisible(restDec);
    await tester.tap(restDec);
    await tester.pumpAndSettle();

    final restAfterInc = find.byKey(
      const Key('exercise_rest_after_duration_stepper_sec_increment'),
    );
    await tester.ensureVisible(restAfterInc);
    await tester.tap(restAfterInc);
    await tester.pumpAndSettle();

    final saveButton = find.byKey(const Key('exercise_save_button'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.name, 'Burpees');
    expect(result!.sets, 4);
    expect(result!.workSeconds, 45);
    expect(result!.restSeconds, 15);
    expect(result!.restAfterExerciseSeconds, 5);
  });
}
