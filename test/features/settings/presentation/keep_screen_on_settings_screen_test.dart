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
  testWidgets('keep screen on toggle updates visible state (R5)',
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

    // Tall surface still needs scroll once F36 SFX section is present.
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Settings ListView only builds viewport children. F36 SFX section pushed
    // keep-screen below the fold — scroll to lazy-build, then ensure hit-testable.
    final switchFinder = find.byKey(const Key('keep_screen_on_enabled_switch'));
    await tester.scrollUntilVisible(
      switchFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(switchFinder);
    await tester.pumpAndSettle();
    expect(switchFinder, findsOneWidget);

    // Default on
    expect(await settingsRepo.getKeepScreenOnEnabled(), true);

    // Touch target: SwitchListTile is tall enough for 48dp
    final size = tester.getSize(switchFinder);
    expect(size.height, greaterThanOrEqualTo(48));

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(await settingsRepo.getKeepScreenOnEnabled(), false);

    await tester.ensureVisible(switchFinder);
    await tester.pumpAndSettle();
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(await settingsRepo.getKeepScreenOnEnabled(), true);

    // Independent of voice default
    expect(await settingsRepo.getVoiceEnabled(), true);
  });
}
