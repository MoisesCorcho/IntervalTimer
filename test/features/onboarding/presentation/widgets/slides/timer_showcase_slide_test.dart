import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/onboarding/presentation/widgets/slides/timer_showcase_slide.dart';
import 'package:interval_timer/shared/widgets/countdown_ring.dart';

void main() {
  Widget buildSubject() {
    return const MaterialApp(
      home: Scaffold(
        body: TimerShowcaseSlide(),
      ),
    );
  }

  group('TimerShowcaseSlide Animation & Cycle Tests (F30 R5)', () {
    testWidgets('starts with TRABAJO phase at 00:03 and workColor', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('TRABAJO'), findsOneWidget);
      expect(find.text('00:03'), findsOneWidget);
      expect(find.text('Ronda 1/8'), findsOneWidget);

      final ringFinder = find.byType(CountdownRing);
      expect(ringFinder, findsOneWidget);
      final ring = tester.widget<CountdownRing>(ringFinder);
      expect(ring.color, equals(AppTheme.workColor));
      expect(ring.remainingFraction, closeTo(1.0, 0.05));
    });

    testWidgets('counts down during TRABAJO phase as time elapses', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Advance 1200ms into the 3000ms work phase
      await tester.pump(const Duration(milliseconds: 1200));

      expect(find.text('TRABAJO'), findsOneWidget);
      expect(find.text('00:02'), findsOneWidget);

      final ring = tester.widget<CountdownRing>(find.byType(CountdownRing));
      expect(ring.color, equals(AppTheme.workColor));
      expect(ring.remainingFraction, lessThan(1.0));
      expect(ring.remainingFraction, greaterThan(0.3));
    });

    testWidgets('transitions to DESCANSO phase at 3000ms with restColor and 00:02', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Advance past 3000ms into rest phase (e.g. 3200ms)
      await tester.pump(const Duration(milliseconds: 3200));

      expect(find.text('DESCANSO'), findsOneWidget);
      expect(find.text('00:02'), findsOneWidget);

      final ring = tester.widget<CountdownRing>(find.byType(CountdownRing));
      expect(ring.color, equals(AppTheme.restColor));
    });

    testWidgets('loops seamlessly back to TRABAJO after 5000ms', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Advance past full 5000ms cycle into the next loop
      await tester.pump(const Duration(milliseconds: 5100));

      expect(find.text('TRABAJO'), findsOneWidget);
      expect(find.text('00:03'), findsOneWidget);

      final ring = tester.widget<CountdownRing>(find.byType(CountdownRing));
      expect(ring.color, equals(AppTheme.workColor));
    });

    testWidgets('cleans up animation controllers properly on dispose', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 500));

      // Replace with empty container to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
