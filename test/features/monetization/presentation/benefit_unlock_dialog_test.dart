import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/monetization/application/daily_rewarded_ad_tracker.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/data/temporary_pass_repository.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/monetization/infrastructure/fake_ad_service.dart';
import 'package:interval_timer/features/monetization/presentation/widgets/benefit_unlock_dialog.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late TemporaryPassRepository passRepo;
  late FakeAdService fakeAdService;
  late DailyRewardedAdTracker tracker;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    passRepo = TemporaryPassRepository(db, prefs);
    fakeAdService = FakeAdService(temporaryPassRepository: passRepo);
    tracker = DailyRewardedAdTracker(prefs);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget({
    required RewardedBenefit benefit,
    VoidCallback? onProPressed,
    VoidCallback? onUnlocked,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        temporaryPassRepositoryProvider.overrideWithValue(passRepo),
        adServiceProvider.overrideWithValue(fakeAdService),
        dailyRewardedAdTrackerProvider.overrideWithValue(tracker),
        isProUserProvider.overrideWith((ref) => Stream.value(false)),
        ...overrides,
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                BenefitUnlockDialog.show(
                  context: context,
                  benefit: benefit,
                  onProPressed: onProPressed,
                  onUnlocked: onUnlocked,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  group('BenefitUnlockDialog Widget Tests', () {
    testWidgets('renders title, benefits, and both action buttons', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(benefit: RewardedBenefit.proAudioPass),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Desbloquear Efectos de Sonido Pro'), findsOneWidget);
      expect(find.text('Probar por 12 horas'), findsOneWidget);
      expect(find.text('Desbloquear con Pro'), findsOneWidget);
      expect(find.text('Ver video para desbloquear'), findsOneWidget);
    });

    testWidgets('tapping Ver video unlocks benefit and closes dialog on success', (tester) async {
      fakeAdService.isReady = true;
      fakeAdService.shouldUserCompleteAd = true;

      bool wasUnlocked = false;

      await tester.pumpWidget(
        buildTestWidget(
          benefit: RewardedBenefit.extraWorkoutSlot,
          onUnlocked: () {
            wasUnlocked = true;
          },
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver video para desbloquear'));
      await tester.pumpAndSettle();

      expect(wasUnlocked, isTrue);
      // Dialog should be dismissed
      expect(find.byType(BenefitUnlockDialog), findsNothing);
      expect(await passRepo.hasActivePass(RewardedBenefit.extraWorkoutSlot), isTrue);
    });

    testWidgets('video button is disabled when daily cap is reached', (tester) async {
      final now = DateTime.utc(2026, 9, 15, 10, 0);
      await tracker.recordAdWatched(now);
      await tracker.recordAdWatched(now.add(const Duration(minutes: 20)));

      await tester.pumpWidget(
        buildTestWidget(benefit: RewardedBenefit.phaseColorsPass),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Límite diario alcanzado (2/2)'), findsOneWidget);
      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Límite diario alcanzado (2/2)'),
      );
      expect(button.onPressed, isNull); // Disabled button
    });

    testWidgets('video button displays remaining cooldown countdown and is disabled when cooldown is active', (tester) async {
      final now = DateTime.now().toUtc();
      // Ad watched 5 minutes ago -> remaining cooldown is 10 minutes (10:00)
      final watchedAt = now.subtract(const Duration(minutes: 5));
      await tracker.recordAdWatched(watchedAt);

      await tester.pumpWidget(
        buildTestWidget(benefit: RewardedBenefit.phaseColorsPass),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Disponible en 10:00'), findsOneWidget);
      final button = tester.widget<OutlinedButton>(
        find.byKey(const Key('benefit_unlock_watch_ad_button')),
      );
      expect(button.onPressed, isNull);

      // Advance 1 second and verify it counts down
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Disponible en 09:59'), findsOneWidget);
    });
  });
}
