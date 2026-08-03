import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/lock_screen/domain/no_op_session_surface_driver.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/presentation/settings_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late SettingsRepository settingsRepo;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    settingsRepo = SettingsRepository(prefs);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        preferencesRepositoryProvider.overrideWithValue(prefs),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        sessionSurfaceDriverProvider.overrideWithValue(
          NoOpSessionSurfaceDriver(),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  testWidgets('kg/lb segmented control updates preference (R8)',
      (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('body_weight_unit_settings')), findsOneWidget);
    expect(find.byKey(const Key('body_weight_unit_segmented')), findsOneWidget);
    expect(find.text(UiStrings.bodyWeightUnitKg), findsWidgets);
    expect(find.text(UiStrings.bodyWeightUnitLb), findsOneWidget);

    await tester.tap(find.text(UiStrings.bodyWeightUnitLb));
    await tester.pumpAndSettle();

    final unit = await settingsRepo.getBodyWeightUnit();
    expect(unit, BodyWeightUnit.lb);
    expect(await prefs.getBodyWeightUnit(), 'lb');
  });
}
