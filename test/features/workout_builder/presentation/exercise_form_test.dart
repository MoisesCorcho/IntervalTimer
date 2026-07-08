import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/exercise_form.dart';

void main() {
  testWidgets('exercise form rejects invalid sets and empty name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseForm(onSubmit: (_) {}),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('exercise_name_field')), '');
    await tester.enterText(find.byKey(const Key('exercise_sets_field')), '0');
    await tester.tap(find.byKey(const Key('exercise_save_button')));
    await tester.pump();

    expect(find.text(UiStrings.nameRequired), findsOneWidget);
    expect(find.text(UiStrings.setsInvalid), findsOneWidget);
  });
}