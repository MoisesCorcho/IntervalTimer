import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/onboarding/presentation/onboarding_screen.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PreferencesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject({VoidCallback? onFinished}) {
    return ProviderScope(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: OnboardingScreen(onFinished: onFinished),
      ),
    );
  }

  Future<void> pumpTransition(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('OnboardingScreen Widget Tests (F30)', () {
    testWidgets('renders Slide 1 initially with title, skip button and next action', (tester) async {
      await tester.pumpWidget(buildSubject());
      await pumpTransition(tester);

      expect(find.text('Entrená con precisión absoluta'), findsOneWidget);
      expect(find.text('PRECISIÓN & CONTROL'), findsOneWidget);
      expect(find.text('Saltar'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
    });

    testWidgets('navigates through all 3 slides using Siguiente button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await pumpTransition(tester);

      // Slide 1 -> Slide 2
      await tester.tap(find.text('Siguiente'));
      await pumpTransition(tester);

      expect(find.text('Olvidate de mirar la pantalla'), findsOneWidget);
      expect(find.text('INMERSIÓN & FOCO'), findsOneWidget);

      // Slide 2 -> Slide 3
      await tester.tap(find.text('Siguiente'));
      await pumpTransition(tester);

      expect(find.text('Constancia que se transforma en logros'), findsOneWidget);
      expect(find.text('HÁBITO & LOGROS'), findsOneWidget);
      expect(find.text('¡Empezar a entrenar!'), findsOneWidget);
    });

    testWidgets('tapping Saltar on Slide 1 marks onboarding as completed in repo', (tester) async {
      var finishedCalled = false;
      await tester.pumpWidget(buildSubject(onFinished: () => finishedCalled = true));
      await pumpTransition(tester);

      expect(await repo.hasSeenOnboarding(), isFalse);

      await tester.tap(find.text('Saltar'));
      await pumpTransition(tester);

      expect(await repo.hasSeenOnboarding(), isTrue);
      expect(finishedCalled, isTrue);
    });

    testWidgets('tapping Empezar a entrenar on Slide 3 marks onboarding completed', (tester) async {
      var finishedCalled = false;
      await tester.pumpWidget(buildSubject(onFinished: () => finishedCalled = true));
      await pumpTransition(tester);

      // Go to Slide 2
      await tester.tap(find.text('Siguiente'));
      await pumpTransition(tester);

      // Go to Slide 3
      await tester.tap(find.text('Siguiente'));
      await pumpTransition(tester);

      expect(await repo.hasSeenOnboarding(), isFalse);

      await tester.tap(find.text('¡Empezar a entrenar!'));
      await pumpTransition(tester);

      expect(await repo.hasSeenOnboarding(), isTrue);
      expect(finishedCalled, isTrue);
    });

    testWidgets('renders cleanly in dark theme without overflow or errors (R13)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const OnboardingScreen(),
          ),
        ),
      );
      await pumpTransition(tester);

      expect(find.text('Entrená con precisión absoluta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
