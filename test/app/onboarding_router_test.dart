import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/app/router.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/onboarding/presentation/onboarding_screen.dart';
import 'package:interval_timer/features/preset_routines/presentation/screens/preset_catalog_screen.dart';
import 'package:interval_timer/features/timer/presentation/routine_editor_screen.dart';
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

  Widget buildApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(routerProvider);
          return MaterialApp.router(
            routerConfig: router,
          );
        },
      ),
    );
  }

  group('Onboarding Router Integration Tests (F30)', () {
    testWidgets('redirects to /onboarding on first launch when hasSeenOnboarding is false (R1)', (tester) async {
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildApp(container));
      // Pump initial navigation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('navigates to / (RoutineEditorScreen) when hasSeenOnboarding is already true (R11)', (tester) async {
      await repo.setHasSeenOnboarding(true);

      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(RoutineEditorScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('completing onboarding from screen redirects to /presets (R4, R9)', (tester) async {
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Tap "Saltar" to complete
      await tester.tap(find.text('Saltar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 200));

      expect(await repo.hasSeenOnboarding(), isTrue);
      expect(find.byType(PresetCatalogScreen), findsOneWidget);
    });
  });
}
