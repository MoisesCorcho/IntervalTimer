import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/workout_rounds_card.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required int rounds,
    required ValueChanged<int> onChanged,
    bool enabled = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: WorkoutRoundsCard(
            rounds: rounds,
            onChanged: onChanged,
            enabled: enabled,
          ),
        ),
      ),
    );
  }

  testWidgets('shows title, helper and current rounds value', (tester) async {
    await pumpCard(tester, rounds: 3, onChanged: (_) {});

    expect(find.text(UiStrings.workoutRoundsTitle), findsOneWidget);
    expect(find.text(UiStrings.workoutRoundsHelper), findsOneWidget);
    expect(find.text(UiStrings.workoutRoundsShort), findsOneWidget);
    expect(find.byKey(const Key('workout_rounds_number_stepper_value')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(
      find.text(
        UiStrings.workoutRoundsBlockChip.replaceAll('{count}', '3'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('hides block chip when rounds is 1', (tester) async {
    await pumpCard(tester, rounds: 1, onChanged: (_) {});

    expect(find.byType(Chip), findsNothing);
    expect(
      find.text(UiStrings.workoutRoundsBlockChip.replaceAll('{count}', '1')),
      findsNothing,
    );
  });

  testWidgets('stepper + calls onChanged with incremented value', (tester) async {
    final values = <int>[];
    await pumpCard(tester, rounds: 2, onChanged: values.add);

    await tester.tap(find.byKey(const Key('workout_rounds_number_stepper_increment')));
    await tester.pump();

    expect(values, [3]);
  });

  testWidgets('stepper - calls onChanged with decremented value', (tester) async {
    final values = <int>[];
    await pumpCard(tester, rounds: 5, onChanged: values.add);

    await tester.tap(find.byKey(const Key('workout_rounds_number_stepper_decrement')));
    await tester.pump();

    expect(values, [4]);
  });

  testWidgets('disabled ignores pointer on stepper', (tester) async {
    final values = <int>[];
    await pumpCard(tester, rounds: 2, onChanged: values.add, enabled: false);

    // IgnorePointer blocks hit tests; warnIfMissed would false-positive.
    await tester.tap(
      find.byKey(const Key('workout_rounds_number_stepper_increment')),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(values, isEmpty);
  });
}
