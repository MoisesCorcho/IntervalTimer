import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/always_on/application/always_on_providers.dart';
import 'package:interval_timer/features/always_on/domain/no_op_wakelock_driver.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/lock_screen/domain/no_op_session_surface_driver.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/data/fake_billing_driver.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/presentation/settings_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late SettingsRepository settingsRepo;
  late FakeBillingDriver driver;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    settingsRepo = SettingsRepository(prefs);
    driver = FakeBillingDriver(preferencesRepository: prefs);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        preferencesRepositoryProvider.overrideWithValue(prefs),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        wakelockDriverProvider.overrideWithValue(NoOpWakelockDriver()),
        sessionSurfaceDriverProvider.overrideWithValue(NoOpSessionSurfaceDriver()),
        billingRepositoryProvider.overrideWithValue(driver),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Widget buildTestWidget() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    );
  }

  testWidgets('Settings screen renders Pro Tier card and developer toggle in debug mode (R14)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Scroll to Pro Tier card in ListView
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings_card_pro_tier')),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Verify Pro Tier card at the top
    expect(find.byKey(const Key('settings_card_pro_tier')), findsOneWidget);

    // Scroll to Developer toggle switch at the bottom
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings_debug_pro_toggle')),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Verify Developer toggle switch
    expect(find.byKey(const Key('settings_debug_pro_toggle')), findsOneWidget);
    expect(await prefs.isProUser(), isFalse);

    // Toggle switch ON
    await tester.tap(find.byKey(const Key('settings_debug_pro_toggle')));
    await tester.pumpAndSettle();

    expect(await prefs.isProUser(), isTrue);

    // Scroll back up to Pro Tier card to verify state update
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings_card_pro_tier')),
      -200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Pro Activo'), findsOneWidget);

    // Scroll to toggle switch OFF
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings_debug_pro_toggle')),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_debug_pro_toggle')));
    await tester.pumpAndSettle();

    expect(await prefs.isProUser(), isFalse);

    // Scroll back up to Pro Tier card to verify state update
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings_card_pro_tier')),
      -200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Desbloquea Interval Timer Pro'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
  });
}
