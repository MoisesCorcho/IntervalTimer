import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/shared/widgets/interval_duration_picker.dart';

void main() {
  testWidgets('vertical layout shows unit labels and total', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: IntervalDurationPicker(
            totalSeconds: 125,
            minSeconds: 1,
            maxSeconds: 5999,
            onChanged: (_) {},
            label: UiStrings.duration,
          ),
        ),
      ),
    );

    expect(find.text(UiStrings.minutesLabel), findsOneWidget);
    expect(find.text(UiStrings.secondsLabel), findsOneWidget);
    expect(find.text(UiStrings.totalLabel), findsOneWidget);
    expect(find.text('02:05'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNWidgets(2));
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('long-press accelerates second increments', (tester) async {
    var current = 10;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return IntervalDurationPicker(
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

    final inc = find.byKey(const Key('duration_stepper_sec_increment'));
    final gesture = await tester.startGesture(tester.getCenter(inc));
    // Immediate step on pointer down (+5 → 15), then hold delay + repeats.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pumpAndSettle();

    // Single tap would be +5 (→15); long-press should advance further.
    expect(current, greaterThan(15));
  });
}

