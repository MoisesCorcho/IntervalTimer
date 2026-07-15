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
  testWidgets('keep screen on toggle updates visible state (R5)',
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

    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final switchFinder = find.byKey(const Key('keep_screen_on_enabled_switch'));
    await tester.ensureVisible(switchFinder);
    expect(switchFinder, findsOneWidget);

    // Default on
    expect(await settingsRepo.getKeepScreenOnEnabled(), true);

    // Touch target: SwitchListTile is tall enough for 48dp
    final size = tester.getSize(switchFinder);
    expect(size.height, greaterThanOrEqualTo(48));

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(await settingsRepo.getKeepScreenOnEnabled(), false);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(await settingsRepo.getKeepScreenOnEnabled(), true);

    // Independent of voice default
    expect(await settingsRepo.getVoiceEnabled(), true);
  });
}
