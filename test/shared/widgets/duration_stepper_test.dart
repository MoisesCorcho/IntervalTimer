import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/shared/widgets/duration_stepper.dart';

void main() {
  testWidgets('shows mm:ss and no TextField', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: DurationStepper(
            totalSeconds: 65,
            minSeconds: 1,
            maxSeconds: 5999,
            onChanged: (_) {},
            label: 'Trabajo',
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('duration_stepper_value')), findsOneWidget);
    expect(find.text('01:05'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('+ min and + sec update total on total-seconds model', (
    tester,
  ) async {
    var current = 58;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return DurationStepper(
                totalSeconds: current,
                minSeconds: 1,
                maxSeconds: 5999,
                onChanged: (v) => setState(() => current = v),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('00:58'), findsOneWidget);

    await tester.tap(find.byKey(const Key('duration_stepper_sec_increment')));
    await tester.pumpAndSettle();
    expect(find.text('01:03'), findsOneWidget);

    await tester.tap(find.byKey(const Key('duration_stepper_min_increment')));
    await tester.pumpAndSettle();
    expect(find.text('02:03'), findsOneWidget);
  });

  testWidgets('buttons disabled at edges', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: DurationStepper(
            totalSeconds: 1,
            minSeconds: 1,
            maxSeconds: 5999,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    IconButton iconButton(Key key) {
      return tester.widget<IconButton>(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(IconButton),
        ),
      );
    }

    expect(
      iconButton(const Key('duration_stepper_sec_decrement')).onPressed,
      isNull,
    );
    expect(
      iconButton(const Key('duration_stepper_min_decrement')).onPressed,
      isNull,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: DurationStepper(
            totalSeconds: 5999,
            minSeconds: 1,
            maxSeconds: 5999,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(
      iconButton(const Key('duration_stepper_sec_increment')).onPressed,
      isNull,
    );
    expect(
      iconButton(const Key('duration_stepper_min_increment')).onPressed,
      isNull,
    );
  });
}
