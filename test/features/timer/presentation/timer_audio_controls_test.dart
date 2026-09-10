import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/always_on/application/always_on_providers.dart';
import 'package:interval_timer/features/always_on/domain/no_op_wakelock_driver.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/presentation/timer_execution_screen.dart';
import 'package:interval_timer/features/timer/presentation/widgets/timer_audio_controls_sheet.dart';

Routine _testRoutine() {
  return Routine(
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
}

void main() {
  late DateTime fakeNow;
  late TimerController timerController;
  late ProviderContainer container;
  late AppDatabase db;

  setUp(() {
    fakeNow = DateTime.utc(2026);
    timerController = TimerController(now: () => fakeNow);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        wakelockDriverProvider.overrideWithValue(NoOpWakelockDriver()),
        timerControllerProvider.overrideWith(() => timerController),
      ],
    );
  });

  tearDown(() async {
    container.read(timerControllerProvider.notifier).resetToIdle();
    container.dispose();
    await db.close();
  });

  Future<void> pumpExecution(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TimerExecutionScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('top bar displays audio controls button and opens bottom sheet', (tester) async {
    await pumpExecution(tester);

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(_testRoutine());
    controller.start(prepSeconds: 0);
    controller.pause();
    await tester.pump();

    // Verify audio controls button is present
    final audioBtn = find.byKey(const Key('timer_audio_controls_button'));
    expect(audioBtn, findsOneWidget);

    // Initial state: audio channels enabled -> Icons.tune
    expect(find.descendant(of: audioBtn, matching: find.byIcon(Icons.tune)), findsOneWidget);

    // Tap to open sheet
    await tester.tap(audioBtn);
    await tester.pumpAndSettle();

    // Verify sheet contents
    expect(find.byType(TimerAudioControlsSheet), findsOneWidget);
    expect(find.byKey(const Key('timer_voice_switch')), findsOneWidget);
    expect(find.byKey(const Key('timer_sound_switch')), findsOneWidget);
    expect(find.byKey(const Key('timer_vibration_switch')), findsOneWidget);
    expect(find.byKey(const Key('timer_toggle_all_audio_button')), findsOneWidget);
  });

  testWidgets('sheet toggles switches and mute all / unmute all', (tester) async {
    await pumpExecution(tester);

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(_testRoutine());
    controller.start(prepSeconds: 0);
    controller.pause();
    await tester.pump();

    // Open sheet
    await tester.tap(find.byKey(const Key('timer_audio_controls_button')));
    await tester.pumpAndSettle();

    // Toggle voice switch off
    await tester.tap(find.byKey(const Key('timer_voice_switch')));
    await tester.pumpAndSettle();

    var settings = container.read(settingsControllerProvider).value!;
    expect(settings.voiceEnabled, isFalse);

    // Tap Mute all button
    final toggleAllBtn = find.byKey(const Key('timer_toggle_all_audio_button'));
    await tester.tap(toggleAllBtn);
    await tester.pumpAndSettle();

    settings = container.read(settingsControllerProvider).value!;
    expect(settings.voiceEnabled, isFalse);
    expect(settings.soundEnabled, isFalse);
    expect(settings.vibrationEnabled, isFalse);

    // Tap Unmute all button
    await tester.tap(toggleAllBtn);
    await tester.pumpAndSettle();

    settings = container.read(settingsControllerProvider).value!;
    expect(settings.voiceEnabled, isTrue);
    expect(settings.soundEnabled, isTrue);
    expect(settings.vibrationEnabled, isTrue);
  });

  testWidgets('top bar icon updates to volume_off when all channels are muted', (tester) async {
    await pumpExecution(tester);

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(_testRoutine());
    controller.start(prepSeconds: 0);
    controller.pause();
    await tester.pump();

    // Mute all settings
    final settingsNotifier = container.read(settingsControllerProvider.notifier);
    await settingsNotifier.setVoiceEnabled(false);
    await settingsNotifier.setSoundEnabled(false);
    await settingsNotifier.setVibrationEnabled(false);
    await tester.pump();

    // Button should now have Icons.volume_off
    final audioBtn = find.byKey(const Key('timer_audio_controls_button'));
    expect(find.descendant(of: audioBtn, matching: find.byIcon(Icons.volume_off)), findsOneWidget);
  });
}
