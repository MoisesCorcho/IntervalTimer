import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/presentation/screens/paywall_modal_screen.dart';
import 'package:interval_timer/features/pro_tier/presentation/widgets/pro_badge.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/sound_effects/application/sound_effects_providers.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_player.dart';
import 'package:interval_timer/features/sound_effects/presentation/sound_effects_settings_section.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

class _FakeSfxPlayer implements SfxPlayer {
  final List<String> playedAssets = [];

  @override
  Future<void> playAsset(String assetPath) async {
    playedAssets.add(assetPath);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('SoundEffectsSettingsSection Freemium Gates', () {
    late AppDatabase db;
    late PreferencesRepository prefs;
    late SettingsRepository settingsRepo;
    late _FakeSfxPlayer fakePlayer;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      prefs = PreferencesRepository(db);
      settingsRepo = SettingsRepository(prefs);
      fakePlayer = _FakeSfxPlayer();
    });

    tearDown(() async {
      await db.close();
    });

    Widget buildTestWidget({
      required ProviderContainer container,
      required AppSettings settings,
    }) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: SoundEffectsSettingsSection(settings: settings),
            ),
          ),
        ),
      );
    }

    testWidgets('free user: non-default sound clip has ProBadge and tapping opens Paywall',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sfxPlayerProvider.overrideWithValue(fakePlayer),
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
        ],
      );
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const settings = AppSettings(prepSeconds: 5);
      await tester.pumpWidget(
        buildTestWidget(container: container, settings: settings),
      );
      await tester.pumpAndSettle();

      // Open picker for workStart clip
      final changeBtn = find.byKey(const Key('sound_change_workStart'));
      expect(changeBtn, findsOneWidget);
      await tester.tap(changeBtn);
      await tester.pumpAndSettle();

      // Non-default clip (e.g. sfx_boxing_bell) should show ProBadge
      expect(find.byType(ProBadge), findsWidgets);

      // Tap locked clip
      final bellClip = find.byKey(const Key('sound_pick_sfx_work_start_02'));
      expect(bellClip, findsOneWidget);
      await tester.tap(bellClip);
      await tester.pumpAndSettle();

      // PaywallModalScreen should be displayed
      expect(find.byType(PaywallModalScreen), findsOneWidget);
    });

    testWidgets('free user: tapping preview on locked sound plays preview without paywall',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sfxPlayerProvider.overrideWithValue(fakePlayer),
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
        ],
      );
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const settings = AppSettings(prepSeconds: 5);
      await tester.pumpWidget(
        buildTestWidget(container: container, settings: settings),
      );
      await tester.pumpAndSettle();

      // Open picker for workStart clip
      await tester.tap(find.byKey(const Key('sound_change_workStart')));
      await tester.pumpAndSettle();

      // Tap preview button on sfx_work_start_02
      final bellPickerItem = find.byKey(const Key('sound_pick_sfx_work_start_02'));
      final previewIcon = find.descendant(
        of: bellPickerItem,
        matching: find.byType(IconButton),
      );
      expect(previewIcon, findsOneWidget);

      await tester.tap(previewIcon);
      await tester.pump();

      // Should have played the sound preview
      expect(fakePlayer.playedAssets, isNotEmpty);
      expect(fakePlayer.playedAssets.first, contains('work_start_02'));
      // Should NOT open paywall
      expect(find.byType(PaywallModalScreen), findsNothing);
    });

    testWidgets('pro user: tapping non-default sound clip selects it',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sfxPlayerProvider.overrideWithValue(fakePlayer),
          isProUserProvider.overrideWith((ref) => Stream.value(true)),
        ],
      );
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const settings = AppSettings(prepSeconds: 5);
      await tester.pumpWidget(
        buildTestWidget(container: container, settings: settings),
      );
      await tester.pumpAndSettle();

      // Open picker for workStart clip
      await tester.tap(find.byKey(const Key('sound_change_workStart')));
      await tester.pumpAndSettle();

      // Tap non-default clip
      final bellClip = find.byKey(const Key('sound_pick_sfx_work_start_02'));
      await tester.tap(bellClip);
      await tester.pumpAndSettle();

      // Picker sheet should close and setting should be updated
      expect(await settingsRepo.getSoundIdWorkStart(), 'sfx_work_start_02');
      expect(find.byType(PaywallModalScreen), findsNothing);
    });
  });
}
