import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/presentation/settings_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  testWidgets('voice toggles and countdown stepper update state',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final prefs = PreferencesRepository(db);
    final settingsRepo = SettingsRepository(prefs);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        preferencesRepositoryProvider.overrideWithValue(prefs),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
      ],
    );
    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('voice_enabled_switch')), findsOneWidget);
    expect(
      find.byKey(const Key('announce_interval_name_switch')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('countdown_seconds_stepper')), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('countdown_number_stepper_increment')),
    );
    await tester.pumpAndSettle();

    expect(await settingsRepo.getCountdownSeconds(), 4);

    await tester.tap(find.byKey(const Key('voice_enabled_switch')));
    await tester.pumpAndSettle();
    expect(await settingsRepo.getVoiceEnabled(), false);

    await tester.tap(find.byKey(const Key('announce_interval_name_switch')));
    await tester.pumpAndSettle();
    // Disabled when voice is off — should remain true
    expect(await settingsRepo.getAnnounceIntervalName(), true);
  });
}
