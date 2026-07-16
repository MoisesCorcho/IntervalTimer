import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/utils/local_date_format.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';
import 'package:interval_timer/features/session_summary/domain/session_phase_breakdown.dart';
import 'package:interval_timer/features/session_summary/domain/share_image_renderer.dart';
import 'package:interval_timer/features/session_summary/domain/share_sheet_driver.dart';
import 'package:interval_timer/features/stats/application/stats_providers.dart';
import 'package:interval_timer/features/stats/domain/stats_service.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:share_plus/share_plus.dart';

typedef ShareTempFileWriter = Future<XFile> Function(Uint8List bytes);

/// Coordinates post-session UI: metrics, share, note, Listo (F16).
class SessionSummaryController extends Notifier<SessionSummaryState> {
  SessionSummaryController({
    this.logResolveAttempts = 8,
    this.logResolveDelay = const Duration(milliseconds: 80),
    StatsService? statsService,
    SessionLogRepository? repository,
    ShareSheetDriver? shareDriver,
    ShareImageRenderer? imageRenderer,
    ShareTempFileWriter? tempFileWriter,
    DateTime Function()? now,
  })  : _injectedStats = statsService,
        _injectedRepo = repository,
        _injectedShare = shareDriver,
        _injectedRenderer = imageRenderer,
        _tempFileWriter = tempFileWriter ?? writeSharePngToTemp,
        _now = now ?? DateTime.now;

  final int logResolveAttempts;
  final Duration logResolveDelay;
  final StatsService? _injectedStats;
  final SessionLogRepository? _injectedRepo;
  final ShareSheetDriver? _injectedShare;
  final ShareImageRenderer? _injectedRenderer;
  final ShareTempFileWriter _tempFileWriter;
  final DateTime Function() _now;

  ShareImageRenderer? _runtimeRenderer;
  bool _bootstrapped = false;
  bool _resolveInFlight = false;

  StatsService get _stats =>
      _injectedStats ?? ref.read(statsServiceProvider);

  SessionLogRepository get _repo =>
      _injectedRepo ?? ref.read(sessionLogRepositoryProvider);

  ShareSheetDriver get _share =>
      _injectedShare ?? PluginShareSheetDriver();

  ShareImageRenderer? get _renderer =>
      _runtimeRenderer ?? _injectedRenderer;

  @override
  SessionSummaryState build() => SessionSummaryState.initial;

  /// Binds a [RepaintBoundary] capture renderer from the screen.
  /// Does not override an injected renderer (tests).
  void attachRenderer(ShareImageRenderer renderer) {
    if (_injectedRenderer != null) return;
    _runtimeRenderer = renderer;
  }

  /// Builds view data from the completed timer session and resolves log id.
  Future<void> bootstrap() async {
    if (_bootstrapped && state.viewData != null) return;
    final timer = ref.read(timerControllerProvider);
    if (timer.status != TimerStatus.completed) {
      state = SessionSummaryState.initial;
      return;
    }
    final routine = timer.routine;
    if (routine == null) return;

    _bootstrapped = true;
    final intervals = _intervalsOf(routine.items);
    final breakdown = SessionPhaseBreakdown.fromIntervals(intervals);
    final planTotal = intervals.fold<int>(
      0,
      (sum, i) => sum + i.durationSeconds,
    );
    final totalSeconds = planTotal;
    final displayName = routine.name.trim().isEmpty
        ? 'Entrenamiento'
        : routine.name.trim();

    final weight = ref.read(userWeightKgProvider);
    final tempLog = _syntheticLog(
      sourceId: routine.id,
      displayName: displayName,
      totalDurationSeconds: totalSeconds,
      itemCount: intervals.length,
    );
    final kcal = _stats
        .estimatedKcalForSession(tempLog, weightKg: weight.weightKg)
        .round();

    var streak = 0;
    try {
      final logs = await _repo.getAll();
      streak = _stats.currentStreak(logs, now: _now());
    } catch (_) {
      streak = 0;
    }

    state = state.copyWith(
      viewData: SessionCompleteViewData.fromBreakdown(
        sourceId: routine.id,
        displayName: displayName,
        totalDurationSeconds: totalSeconds,
        breakdown: breakdown,
        estimatedKcal: kcal,
        currentStreakDays: streak,
        setsCount: breakdown.setsCount,
      ),
      noteDraft: '',
      shareError: false,
      noteError: false,
      noteSaveFailed: false,
      logResolveTimedOut: false,
      discardNoteOnNextDone: false,
    );

    await _resolveSessionLogId(routine.id);
  }

  /// Used in tests when timer state is mocked separately.
  Future<void> bootstrapFromPayload({
    required String sourceId,
    required String displayName,
    required List<Interval> intervals,
    int? totalDurationSeconds,
  }) async {
    _bootstrapped = true;
    final breakdown = SessionPhaseBreakdown.fromIntervals(intervals);
    final total = totalDurationSeconds ??
        intervals.fold<int>(0, (s, i) => s + i.durationSeconds);
    final weight = ref.read(userWeightKgProvider);
    final tempLog = _syntheticLog(
      sourceId: sourceId,
      displayName: displayName,
      totalDurationSeconds: total,
      itemCount: intervals.length,
    );
    final kcal = _stats
        .estimatedKcalForSession(tempLog, weightKg: weight.weightKg)
        .round();
    var streak = 0;
    try {
      final logs = await _repo.getAll();
      streak = _stats.currentStreak(logs, now: _now());
    } catch (_) {}

    state = state.copyWith(
      viewData: SessionCompleteViewData.fromBreakdown(
        sourceId: sourceId,
        displayName: displayName,
        totalDurationSeconds: total,
        breakdown: breakdown,
        estimatedKcal: kcal,
        currentStreakDays: streak,
        setsCount: breakdown.setsCount,
      ),
    );
    await _resolveSessionLogId(sourceId);
  }

  void updateNoteDraft(String value) {
    final clipped = value.length > kSessionNoteMaxLength
        ? value.substring(0, kSessionNoteMaxLength)
        : value;
    state = state.copyWith(
      noteDraft: clipped,
      noteError: false,
      noteSaveFailed: false,
      discardNoteOnNextDone: false,
    );
  }

  void discardNoteDraft() {
    state = state.copyWith(
      noteDraft: '',
      noteError: false,
      noteSaveFailed: false,
      discardNoteOnNextDone: true,
    );
  }

  Future<ShareOutcome> share({Rect? sharePositionOrigin}) async {
    final view = state.viewData;
    final renderer = _renderer;
    if (view == null || renderer == null) {
      state = state.copyWith(shareError: true);
      return ShareOutcome.failed;
    }
    if (state.isSharing) return ShareOutcome.failed;

    state = state.copyWith(isSharing: true, shareError: false);
    try {
      final card = ShareCardData.fromView(view);
      final bytes = await renderer.renderPng(card);
      final file = await _tempFileWriter(bytes);
      final outcome = await _share.shareImage(
        file: file,
        sharePositionOrigin: sharePositionOrigin,
      );
      if (outcome == ShareOutcome.failed ||
          outcome == ShareOutcome.unavailable) {
        state = state.copyWith(isSharing: false, shareError: true);
      } else {
        state = state.copyWith(isSharing: false, shareError: false);
      }
      return outcome;
    } catch (_) {
      state = state.copyWith(isSharing: false, shareError: true);
      return ShareOutcome.failed;
    }
  }

  /// Persists dirty note if needed, then resets timer to idle.
  /// Returns `true` when the screen should navigate away.
  Future<bool> finish() async {
    if (state.isFinishing) return false;
    state = state.copyWith(isFinishing: true, noteError: false);

    final view = state.viewData;
    final draft = state.noteDraft.trim();
    final shouldSaveNote = draft.isNotEmpty &&
        !state.discardNoteOnNextDone &&
        view?.sessionLogId != null;

    if (shouldSaveNote) {
      if (draft.length > kSessionNoteMaxLength) {
        state = state.copyWith(
          isFinishing: false,
          noteError: true,
          noteSaveFailed: true,
        );
        return false;
      }
      try {
        await _repo.updateNote(view!.sessionLogId!, draft);
      } catch (_) {
        state = state.copyWith(
          isFinishing: false,
          noteError: true,
          noteSaveFailed: true,
        );
        return false;
      }
    }

    // Second Listo after failed note: leave without note.
    ref.read(timerControllerProvider.notifier).resetToIdle();
    state = state.copyWith(isFinishing: false);
    _bootstrapped = false;
    return true;
  }

  /// After note save failure, allow Listo without saving.
  Future<bool> finishDiscardingNote() async {
    state = state.copyWith(discardNoteOnNextDone: true, noteDraft: '');
    return finish();
  }

  Future<void> _resolveSessionLogId(String sourceId) async {
    if (_resolveInFlight) return;
    _resolveInFlight = true;
    try {
      for (var i = 0; i < logResolveAttempts; i++) {
        try {
          final log = await _repo.latestCompletedForSource(sourceId);
          if (log != null) {
            final current = state.viewData;
            if (current == null) return;
            final weight = ref.read(userWeightKgProvider);
            final kcal = _stats
                .estimatedKcalForSession(log, weightKg: weight.weightKg)
                .round();
            var streak = current.currentStreakDays;
            try {
              final logs = await _repo.getAll();
              streak = _stats.currentStreak(logs, now: _now());
            } catch (_) {}

            state = state.copyWith(
              viewData: current.copyWith(
                sessionLogId: log.id,
                totalDurationSeconds: log.totalDurationSeconds,
                estimatedKcal: kcal,
                currentStreakDays: streak,
                displayName: log.displayName.trim().isEmpty
                    ? current.displayName
                    : log.displayName.trim(),
              ),
              logResolveTimedOut: false,
            );
            return;
          }
        } catch (_) {
          // retry
        }
        await Future<void>.delayed(logResolveDelay);
      }
      state = state.copyWith(logResolveTimedOut: true);
    } finally {
      _resolveInFlight = false;
    }
  }

  static List<Interval> _intervalsOf(List<RoutineItem> items) {
    return [
      for (final item in items)
        if (item is IntervalRoutineItem) item.interval,
    ];
  }

  SessionLog _syntheticLog({
    required String sourceId,
    required String displayName,
    required int totalDurationSeconds,
    required int itemCount,
  }) {
    final now = _now();
    return SessionLog(
      id: 'temp',
      sourceId: sourceId,
      displayName: displayName,
      endedAt: now.toUtc(),
      localDate: LocalDateFormat.fromDateTime(now),
      status: SessionLogStatus.completed,
      totalDurationSeconds: totalDurationSeconds,
      itemCount: itemCount,
    );
  }
}
