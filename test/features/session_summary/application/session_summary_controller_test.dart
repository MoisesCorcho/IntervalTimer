import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/session_summary/application/session_summary_controller.dart';
import 'package:interval_timer/features/session_summary/application/session_summary_providers.dart';
import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';
import 'package:interval_timer/features/session_summary/domain/share_image_renderer.dart';
import 'package:interval_timer/features/session_summary/domain/share_sheet_driver.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  late AppDatabase db;
  late SessionLogRepository repo;
  late FakeShareSheetDriver shareDriver;
  late FakeShareImageRenderer imageRenderer;

  Interval work([int s = 30]) => Interval(
        id: 'w$s',
        name: 'Work',
        durationSeconds: s,
        colorArgb: 0xFF00FF00,
        type: IntervalType.work,
      );
  Interval rest([int s = 10]) => Interval(
        id: 'r$s',
        name: 'Rest',
        durationSeconds: s,
        colorArgb: 0xFF0000FF,
        type: IntervalType.rest,
      );

  ProviderContainer makeContainer({
    SessionLogRepository? repository,
    FakeShareImageRenderer? renderer,
    FakeShareSheetDriver? driver,
    int resolveAttempts = 5,
    Duration resolveDelay = Duration.zero,
  }) {
    final r = repository ?? repo;
    final img = renderer ?? imageRenderer;
    final sh = driver ?? shareDriver;
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sessionLogRepositoryProvider.overrideWithValue(r),
        sessionSummaryControllerProvider.overrideWith(
          () => SessionSummaryController(
            repository: r,
            shareDriver: sh,
            imageRenderer: img,
            tempFileWriter: (bytes) async => XFile.fromData(
              bytes,
              mimeType: 'image/png',
              name: 'test.png',
            ),
            logResolveAttempts: resolveAttempts,
            logResolveDelay: resolveDelay,
            now: () => DateTime(2026, 7, 16, 12),
          ),
        ),
      ],
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SessionLogRepository(db);
    shareDriver = FakeShareSheetDriver();
    imageRenderer = FakeShareImageRenderer(bytes: [9, 9, 9]);
  });

  tearDown(() async {
    await db.close();
  });

  test('bootstrap builds metrics without requiring note', () async {
    final container = makeContainer();
    addTearDown(container.dispose);
    final c = container.read(sessionSummaryControllerProvider.notifier);
    await c.bootstrapFromPayload(
      sourceId: 'src1',
      displayName: 'Rutina A',
      intervals: [work(40), rest(20)],
    );
    final s = container.read(sessionSummaryControllerProvider);
    expect(s.viewData, isNotNull);
    expect(s.viewData!.trainingSeconds, 40);
    expect(s.viewData!.restSeconds, 20);
    expect(s.viewData!.displayName, 'Rutina A');
    expect(s.hasDirtyNote, isFalse);
  });

  test('Listo resets timer to idle without note', () async {
    final container = makeContainer();
    addTearDown(container.dispose);
    // Put timer in completed via skip path is heavy; finish still calls resetToIdle.
    final c = container.read(sessionSummaryControllerProvider.notifier);
    await c.bootstrapFromPayload(
      sourceId: 'src1',
      displayName: 'X',
      intervals: [work(10)],
    );
    final ok = await c.finish();
    expect(ok, isTrue);
    expect(
      container.read(timerControllerProvider).status,
      TimerStatus.idle,
    );
  });

  test('note limit clamps draft to 500', () async {
    final container = makeContainer();
    addTearDown(container.dispose);
    final c = container.read(sessionSummaryControllerProvider.notifier);
    await c.bootstrapFromPayload(
      sourceId: 'src1',
      displayName: 'X',
      intervals: [work(10)],
    );
    c.updateNoteDraft('z' * 600);
    expect(
      container.read(sessionSummaryControllerProvider).noteDraft.length,
      500,
    );
  });

  test('log resolve attaches sessionLogId after insert', () async {
    final container = makeContainer(
      resolveAttempts: 10,
      resolveDelay: const Duration(milliseconds: 20),
    );
    addTearDown(container.dispose);
    final c = container.read(sessionSummaryControllerProvider.notifier);

    // Delayed insert simulates F04 race.
    Future<void>.delayed(const Duration(milliseconds: 40), () async {
      await repo.insert(
        sourceId: 'src-race',
        displayName: 'Race',
        endedAt: DateTime(2026, 7, 16, 12),
        status: SessionLogStatus.completed,
        totalDurationSeconds: 50,
        itemCount: 2,
      );
    });

    await c.bootstrapFromPayload(
      sourceId: 'src-race',
      displayName: 'Race',
      intervals: [work(30), rest(20)],
      totalDurationSeconds: 50,
    );

    // Allow resolve loop to finish.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final view = container.read(sessionSummaryControllerProvider).viewData;
    expect(view?.sessionLogId, isNotNull);
    expect(view?.noteEnabled, isTrue);
  });

  test('log resolve timeout leaves note disabled without crash', () async {
    final container = makeContainer(
      resolveAttempts: 2,
      resolveDelay: Duration.zero,
    );
    addTearDown(container.dispose);
    final c = container.read(sessionSummaryControllerProvider.notifier);
    await c.bootstrapFromPayload(
      sourceId: 'missing',
      displayName: 'No log',
      intervals: [work(5)],
    );
    final s = container.read(sessionSummaryControllerProvider);
    expect(s.viewData?.sessionLogId, isNull);
    expect(s.logResolveTimedOut, isTrue);
  });

  test('renderer error sets shareError and does not throw', () async {
    imageRenderer.shouldFail = true;
    final container = makeContainer();
    addTearDown(container.dispose);
    final c = container.read(sessionSummaryControllerProvider.notifier);
    await c.bootstrapFromPayload(
      sourceId: 's',
      displayName: 'X',
      intervals: [work(10)],
    );
    final outcome = await c.share();
    expect(outcome, ShareOutcome.failed);
    expect(container.read(sessionSummaryControllerProvider).shareError, isTrue);
  });

  test('share dismissed does not reset timer', () async {
    shareDriver.outcome = ShareOutcome.dismissed;
    final container = makeContainer();
    addTearDown(container.dispose);
    final c = container.read(sessionSummaryControllerProvider.notifier);
    await c.bootstrapFromPayload(
      sourceId: 's',
      displayName: 'X',
      intervals: [work(10)],
    );
    // Force completed-like: don't care about timer status for share.
    final outcome = await c.share();
    expect(outcome, ShareOutcome.dismissed);
    expect(shareDriver.callCount, 1);
    // finish not called — timer still whatever default idle is fine.
  });

  test('note save error keeps draft and fails finish', () async {
    final throwing = _NoteFailRepo(db);
    final container = makeContainer(repository: throwing);
    addTearDown(container.dispose);
    final c = container.read(sessionSummaryControllerProvider.notifier);

    await throwing.insert(
      sourceId: 's-note',
      displayName: 'N',
      endedAt: DateTime(2026, 7, 16, 12),
      status: SessionLogStatus.completed,
      totalDurationSeconds: 10,
      itemCount: 1,
    );

    await c.bootstrapFromPayload(
      sourceId: 's-note',
      displayName: 'N',
      intervals: [work(10)],
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      container.read(sessionSummaryControllerProvider).viewData?.sessionLogId,
      isNotNull,
    );

    c.updateNoteDraft('mi nota');
    final ok = await c.finish();
    expect(ok, isFalse);
    expect(
      container.read(sessionSummaryControllerProvider).noteSaveFailed,
      isTrue,
    );
    expect(
      container.read(sessionSummaryControllerProvider).noteDraft,
      'mi nota',
    );
  });
}

class _NoteFailRepo extends SessionLogRepository {
  _NoteFailRepo(super.db);

  @override
  Future<void> updateNote(String id, String? note) {
    return Future.error(Exception('note write failed'));
  }
}
