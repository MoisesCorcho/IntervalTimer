import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/always_on/application/always_on_providers.dart';
import 'package:interval_timer/features/always_on/domain/no_op_wakelock_driver.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/settings/application/settings_controller.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/presentation/timer_execution_screen.dart';
class _FakeSettingsController extends SettingsController {
  final AppSettings _settings;
  _FakeSettingsController(this._settings);

  @override
  Future<AppSettings> build() async => _settings;
}

void main() {
  testWidgets('execution screen shows time, current and next interval', (
    tester,
  ) async {
    final routine = Routine(
      id: 'r1',
      name: 'Test',
      createdAt: DateTime.utc(2026),
      items: [
        RoutineItem.interval(
          Interval(
            id: 'i1',
            name: 'Trabajo',
            durationSeconds: 60,
            colorArgb: 0xFF4CAF50,
          ),
        ),
        RoutineItem.interval(
          Interval(
            id: 'i2',
            name: 'Descanso',
            durationSeconds: 30,
            colorArgb: 0xFF2196F3,
          ),
        ),
      ],
    );

    // Isolated in-memory DB so F19 always-on → settings prefs do not open a second AppDatabase.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final timerController =
        TimerController(now: () => DateTime.utc(2026));
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        wakelockDriverProvider.overrideWithValue(NoOpWakelockDriver()),
        timerControllerProvider.overrideWith(() => timerController),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TimerExecutionScreen()),
      ),
    );

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(routine);
    controller.start(prepSeconds: 0);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('countdown_display')), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
    expect(find.byKey(const Key('current_interval_name')), findsOneWidget);
    expect(find.text('TRABAJO'), findsOneWidget);
    expect(find.text(UiStrings.nextInterval), findsWidgets);
    expect(find.text('DESCANSO'), findsOneWidget);

    controller.pause();
    await tester.pump();
  });

  testWidgets(
      'falls back to AppTheme.workColor when user has custom color in settings but phaseColorsPass is inactive',
      (tester) async {
    const customPurple = 0xFF9C27B0;
    final routine = Routine(
      id: 'r1',
      name: 'Test',
      createdAt: DateTime.utc(2026),
      items: [
        RoutineItem.interval(
          Interval(
            id: 'i1',
            name: 'Trabajo',
            durationSeconds: 60,
            colorArgb: 0xFF4CAF50,
          ),
        ),
      ],
    );

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final timerController = TimerController(now: () => DateTime.utc(2026));
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        wakelockDriverProvider.overrideWithValue(NoOpWakelockDriver()),
        timerControllerProvider.overrideWith(() => timerController),
        settingsControllerProvider.overrideWith(
          () => _FakeSettingsController(
            const AppSettings(prepSeconds: 5, workColorArgb: customPurple),
          ),
        ),
        isBenefitUnlockedProvider(RewardedBenefit.phaseColorsPass)
            .overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TimerExecutionScreen()),
      ),
    );
    await tester.pump();

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(routine);
    controller.start(prepSeconds: 0);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.workColor);

    controller.pause();
    await tester.pump();
  });

  testWidgets(
      'uses custom workColor from settings when phaseColorsPass is active',
      (tester) async {
    const customPurple = 0xFF9C27B0;
    final routine = Routine(
      id: 'r1',
      name: 'Test',
      createdAt: DateTime.utc(2026),
      items: [
        RoutineItem.interval(
          Interval(
            id: 'i1',
            name: 'Trabajo',
            durationSeconds: 60,
            colorArgb: 0xFF4CAF50,
          ),
        ),
      ],
    );

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final timerController = TimerController(now: () => DateTime.utc(2026));
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        wakelockDriverProvider.overrideWithValue(NoOpWakelockDriver()),
        timerControllerProvider.overrideWith(() => timerController),
        settingsControllerProvider.overrideWith(
          () => _FakeSettingsController(
            const AppSettings(prepSeconds: 5, workColorArgb: customPurple),
          ),
        ),
        isBenefitUnlockedProvider(RewardedBenefit.phaseColorsPass)
            .overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TimerExecutionScreen()),
      ),
    );
    await tester.pump();

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(routine);
    controller.start(prepSeconds: 0);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(customPurple));

    controller.pause();
    await tester.pump();
  });
}