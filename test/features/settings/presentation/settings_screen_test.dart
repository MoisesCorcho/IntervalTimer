import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/lock_screen/domain/no_op_session_surface_driver.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/presentation/screens/paywall_modal_screen.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';
import 'package:interval_timer/features/settings/presentation/settings_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  group('SettingsScreen', () {
    late AppDatabase db;
    late PreferencesRepository prefs;
    late SettingsRepository settingsRepo;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      prefs = PreferencesRepository(db);
      settingsRepo = SettingsRepository(prefs);
      final sessionSurface = NoOpSessionSurfaceDriver();

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sessionSurfaceDriverProvider.overrideWithValue(sessionSurface),
          isProUserProvider.overrideWith((ref) => Stream.value(true)),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    testWidgets('shows stepper and changing value updates repo',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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

    testWidgets('shows theme segmented button with 3 options',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('theme_segmented_button')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('theme_segmented_button')),
          matching: find.text(UiStrings.themeLight),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('theme_segmented_button')),
          matching: find.text(UiStrings.themeDark),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('theme_segmented_button')),
          matching: find.text(UiStrings.themeSystem),
        ),
        findsOneWidget,
      );
    });

    testWidgets('default theme selection is system', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<SegmentedButton<AppThemeMode>>(
        find.byKey(const Key('theme_segmented_button')),
      );
      expect(button.selected, {AppThemeMode.system});
    });

    testWidgets('selecting dark persists and updates repo', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.themeDark));
      await tester.pumpAndSettle();

      expect(await settingsRepo.getThemeMode(), AppThemeMode.dark);

      final button = tester.widget<SegmentedButton<AppThemeMode>>(
        find.byKey(const Key('theme_segmented_button')),
      );
      expect(button.selected, {AppThemeMode.dark});
    });

    testWidgets('shows work and rest color tiles and tapping opens picker sheet',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('work_color_tile')),
        200.0,
      );
      await tester.ensureVisible(find.byKey(const Key('work_color_tile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('work_color_tile')), findsOneWidget);
      expect(find.byKey(const Key('rest_color_tile')), findsOneWidget);

      // Tap work color tile opens screen
      await tester.tap(find.byKey(const Key('work_color_tile')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('preview_phone_frame')), findsOneWidget);
    });

    testWidgets('renders all settings grouped into distinct section cards',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_card_appearance')), findsOneWidget);
      expect(find.byKey(const Key('settings_card_timer')), findsOneWidget);
      expect(find.byKey(const Key('settings_card_voice')), findsOneWidget);

      final sfxFinder = find.byKey(const Key('settings_card_sound_effects'));
      await tester.scrollUntilVisible(sfxFinder, 300, scrollable: find.byType(Scrollable).first);
      expect(sfxFinder, findsOneWidget);

      final vibFinder = find.byKey(const Key('settings_card_vibration'));
      await tester.scrollUntilVisible(vibFinder, 300, scrollable: find.byType(Scrollable).first);
      expect(vibFinder, findsOneWidget);

      final screenFinder = find.byKey(const Key('settings_card_screen_session'));
      await tester.scrollUntilVisible(screenFinder, 300, scrollable: find.byType(Scrollable).first);
      expect(screenFinder, findsOneWidget);
    });

    testWidgets('renders theme accent color swatches and selecting a color updates repo',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_accent_color_selector')), findsOneWidget);

      // Default is orange; tap the athletic green swatch (0xFF4CAF50)
      final greenSwatch = find.byKey(const Key('accent_color_swatch_4283215696')); // 0xFF4CAF50
      expect(greenSwatch, findsOneWidget);

      await tester.tap(greenSwatch);
      await tester.pumpAndSettle();

      expect(await settingsRepo.getThemeColorArgb(), 0xFF4CAF50);
    });

    testWidgets('free user tapping locked accent color opens Paywall and does not update repo',
        (tester) async {
      final freeContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sessionSurfaceDriverProvider.overrideWithValue(NoOpSessionSurfaceDriver()),
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
        ],
      );
      addTearDown(freeContainer.dispose);

      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: freeContainer,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final greenSwatch = find.byKey(const Key('accent_color_swatch_4283215696'));
      expect(greenSwatch, findsOneWidget);

      await tester.tap(greenSwatch);
      await tester.pumpAndSettle();

      expect(find.byType(PaywallModalScreen), findsOneWidget);
      // Repo value should remain default orange
      expect(await settingsRepo.getThemeColorArgb(), 0xFFFF6D00);

      // Close paywall cleanly so no open route or timer leaks
      await tester.tap(find.byKey(const Key('paywall_close_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('free user toggles music ducking freely without paywall',
        (tester) async {
      final freeContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sessionSurfaceDriverProvider.overrideWithValue(NoOpSessionSurfaceDriver()),
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
        ],
      );
      addTearDown(freeContainer.dispose);

      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: freeContainer,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final duckingFinder = find.byKey(const Key('music_ducking_switch'));
      await tester.scrollUntilVisible(duckingFinder, 300,
          scrollable: find.byType(Scrollable).first);
      expect(duckingFinder, findsOneWidget);

      // Default is true; tapping should turn it off without opening Paywall
      await tester.tap(duckingFinder);
      await tester.pumpAndSettle();

      expect(find.byType(PaywallModalScreen), findsNothing);
      expect(await settingsRepo.getMusicDuckingEnabled(), isFalse);
    });

    testWidgets('renders pro tier section card with localized title Repulse Pro',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final proCardFinder = find.byKey(const Key('settings_card_pro_tier'));
      await tester.scrollUntilVisible(proCardFinder, 300,
          scrollable: find.byType(Scrollable).first);
      expect(proCardFinder, findsOneWidget);
      expect(find.text('Repulse Pro'), findsOneWidget);
    });

    testWidgets('shows lock icon on custom phase color when phaseColorsPass is inactive',
        (tester) async {
      await settingsRepo.setWorkColorArgb(0xFF9C27B0); // Custom purple
      final customColorContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sessionSurfaceDriverProvider.overrideWithValue(NoOpSessionSurfaceDriver()),
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
          isBenefitUnlockedProvider(RewardedBenefit.phaseColorsPass).overrideWithValue(false),
        ],
      );
      addTearDown(customColorContainer.dispose);

      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: customColorContainer,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final workColorTile = find.byKey(const Key('work_color_tile'));
      expect(workColorTile, findsOneWidget);
      // Lock icon should be visible inside workColorTile trailing
      expect(
        find.descendant(
          of: workColorTile,
          matching: find.byIcon(Icons.lock_rounded),
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not show lock icon on phase color when phaseColorsPass is active',
        (tester) async {
      await settingsRepo.setWorkColorArgb(0xFF9C27B0); // Custom purple
      final unlockedContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sessionSurfaceDriverProvider.overrideWithValue(NoOpSessionSurfaceDriver()),
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
          isBenefitUnlockedProvider(RewardedBenefit.phaseColorsPass).overrideWithValue(true),
        ],
      );
      addTearDown(unlockedContainer.dispose);

      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: unlockedContainer,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final workColorTile = find.byKey(const Key('work_color_tile'));
      expect(workColorTile, findsOneWidget);
      expect(
        find.descendant(
          of: workColorTile,
          matching: find.byIcon(Icons.lock_rounded),
        ),
        findsNothing,
      );
    });
  });
}
