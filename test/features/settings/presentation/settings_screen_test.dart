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
  testWidgets('settings shows stepper and changing value updates repo',
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('prep_seconds_stepper')), findsOneWidget);
    expect(find.byKey(const Key('prep_number_stepper_value')), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    await tester.tap(find.byKey(const Key('prep_number_stepper_increment')));
    await tester.pumpAndSettle();

    expect(await settingsRepo.getPrepSeconds(), 11);
    expect(find.text('11'), findsOneWidget);
  });
}
