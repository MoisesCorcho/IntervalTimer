import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/lock_screen/domain/no_op_session_surface_driver.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/presentation/settings_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  testWidgets('vibration toggles and countdown stepper update state',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final prefs = PreferencesRepository(db);
    final settingsRepo = SettingsRepository(prefs);
    final sessionSurface = NoOpSessionSurfaceDriver();
    addTearDown(sessionSurface.dispose);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        preferencesRepositoryProvider.overrideWithValue(prefs),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        sessionSurfaceDriverProvider.overrideWithValue(sessionSurface),
      ],
    );
    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vibration_enabled_switch')), findsOneWidget);
    expect(
      find.byKey(const Key('vibration_on_interval_start_switch')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('vibration_on_countdown_switch')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('vibration_countdown_seconds_stepper')),
      findsOneWidget,
    );

    // Scroll to vibration stepper if needed
    await tester.ensureVisible(
      find.byKey(const Key('vibration_countdown_number_stepper_increment')),
    );
    await tester.tap(
      find.byKey(const Key('vibration_countdown_number_stepper_increment')),
    );
    await tester.pumpAndSettle();

    expect(await settingsRepo.getVibrationCountdownSeconds(), 4);

    await tester.ensureVisible(
      find.byKey(const Key('vibration_enabled_switch')),
    );
    await tester.tap(find.byKey(const Key('vibration_enabled_switch')));
    await tester.pumpAndSettle();
    expect(await settingsRepo.getVibrationEnabled(), false);

    // Granular toggle disabled when master off — remains true
    await tester.tap(
      find.byKey(const Key('vibration_on_interval_start_switch')),
    );
    await tester.pumpAndSettle();
    expect(await settingsRepo.getVibrationOnIntervalStart(), true);

    // Voice still independent default
    expect(await settingsRepo.getVoiceEnabled(), true);
  });
}
