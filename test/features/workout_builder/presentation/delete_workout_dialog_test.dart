import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/delete_workout_dialog.dart';

void main() {
  testWidgets('delete dialog cancel keeps workout unchanged', (tester) async {
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  final result = await showDeleteWorkoutDialog(context);
                  deleted = result == true;
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text(UiStrings.deleteWorkoutTitle), findsOneWidget);
    await tester.tap(find.byKey(const Key('delete_workout_cancel')));
    await tester.pumpAndSettle();

    expect(deleted, isFalse);
  });

  testWidgets('delete dialog has separate destructive confirm button',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showDeleteWorkoutDialog(context),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('delete_workout_cancel')), findsOneWidget);
    expect(find.byKey(const Key('delete_workout_confirm')), findsOneWidget);
    expect(find.text(UiStrings.delete), findsOneWidget);
  });
}