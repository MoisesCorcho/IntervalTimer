import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/app/router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/data/repositories/unlocked_achievement_repository.dart';
import 'package:interval_timer/features/achievements/domain/achievement_catalog.dart';
import 'package:interval_timer/features/achievements/presentation/achievements_entry_tile.dart';
import 'package:interval_timer/features/achievements/presentation/achievements_screen.dart';
import 'package:interval_timer/features/achievements/presentation/achievements_unlocked_sheet.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/calendar_history/presentation/history_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

void main() {
  late AppDatabase db;
  late SessionLogRepository sessionRepo;
  late UnlockedAchievementRepository unlockRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sessionRepo = SessionLogRepository(db);
    unlockRepo = UnlockedAchievementRepository(db);
  });

  tearDown(() async => db.close());

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sessionLogRepositoryProvider.overrideWithValue(sessionRepo),
      ],
    );
  }

  Future<void> pumpHistory(WidgetTester tester, ProviderContainer container) {
    final view = tester.view;
    view.physicalSize = const Size(800, 2200);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
  }

  testWidgets('History shows achievements entry; shell stays 4 tabs (R2, R12)',
      (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('achievements_entry_tile')), findsOneWidget);
    expect(find.text(UiStrings.achievementsEntryTitle), findsOneWidget);
    expect(find.byType(AchievementsEntryTile), findsOneWidget);

    // No 5th nav destination on this isolated History screen
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('AchievementsScreen shows progress for pending (R3)',
      (tester) async {
    await sessionRepo.insert(
      sourceId: 's1',
      displayName: 'Test',
      endedAt: DateTime.utc(2026, 7, 15, 12),
      status: SessionLogStatus.completed,
      totalDurationSeconds: 120,
      itemCount: 1,
    );

    final container = createContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AchievementsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('achievements_screen')), findsOneWidget);
    expect(find.byKey(const Key('achievements_list')), findsOneWidget);
    expect(
      find.byKey(const Key('achievement_tile_first_session')),
      findsOneWidget,
    );
    // Pending sessions_10 progress text
    expect(find.textContaining('/10 sesiones'), findsWidgets);
  });

  testWidgets('unlock sheet lists newly unlocked achievements (R7)',
      (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    final unlocked = kAchievementCatalog
        .where((e) => e.id == 'first_session' || e.id == 'minutes_60')
        .toList();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  key: const Key('open_sheet'),
                  onPressed: () {
                    showAchievementsUnlockedSheet(
                      context: context,
                      unlocked: unlocked,
                    );
                  },
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open_sheet')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('achievements_unlocked_sheet')), findsOneWidget);
    expect(find.byKey(const Key('celebration_item_first_session')), findsOneWidget);
    expect(find.byKey(const Key('celebration_item_minutes_60')), findsOneWidget);
    expect(find.text(UiStrings.achievementsSheetTitle), findsOneWidget);
  });

  testWidgets('router still has 4 shell destinations after F13 route',
      (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.destinations.length, 4);
  });

  test('repository insertIgnore used by controller path is idempotent',
      () async {
    final t1 = DateTime.utc(2026, 7, 1);
    expect(
      await unlockRepo.insertIgnore(
        achievementId: 'first_session',
        unlockedAt: t1,
      ),
      isTrue,
    );
    expect(
      await unlockRepo.insertIgnore(
        achievementId: 'first_session',
        unlockedAt: DateTime.utc(2026, 8, 1),
      ),
      isFalse,
    );
    final all = await unlockRepo.getAll();
    expect(all.single.unlockedAt, t1);
  });
}
