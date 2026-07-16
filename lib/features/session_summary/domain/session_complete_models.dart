import 'package:interval_timer/features/session_summary/domain/session_phase_breakdown.dart';

/// Presentation model for post-session screen (F16, not persisted).
class SessionCompleteViewData {
  const SessionCompleteViewData({
    required this.sourceId,
    required this.displayName,
    required this.totalDurationSeconds,
    required this.trainingSeconds,
    required this.restSeconds,
    required this.estimatedKcal,
    required this.currentStreakDays,
    this.setsCount = 0,
    this.sessionLogId,
  });

  final String sourceId;
  final String displayName;
  final int totalDurationSeconds;
  final int trainingSeconds;
  final int restSeconds;
  final int estimatedKcal;
  final int currentStreakDays;

  /// Work-phase intervals count (shown as "Sets" on share templates).
  final int setsCount;
  final String? sessionLogId;

  bool get noteEnabled => sessionLogId != null;

  SessionCompleteViewData copyWith({
    String? sourceId,
    String? displayName,
    int? totalDurationSeconds,
    int? trainingSeconds,
    int? restSeconds,
    int? estimatedKcal,
    int? currentStreakDays,
    int? setsCount,
    String? sessionLogId,
    bool clearSessionLogId = false,
  }) {
    return SessionCompleteViewData(
      sourceId: sourceId ?? this.sourceId,
      displayName: displayName ?? this.displayName,
      totalDurationSeconds:
          totalDurationSeconds ?? this.totalDurationSeconds,
      trainingSeconds: trainingSeconds ?? this.trainingSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      estimatedKcal: estimatedKcal ?? this.estimatedKcal,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      setsCount: setsCount ?? this.setsCount,
      sessionLogId: clearSessionLogId
          ? null
          : (sessionLogId ?? this.sessionLogId),
    );
  }

  factory SessionCompleteViewData.fromBreakdown({
    required String sourceId,
    required String displayName,
    required int totalDurationSeconds,
    required SessionPhaseBreakdown breakdown,
    required int estimatedKcal,
    required int currentStreakDays,
    int setsCount = 0,
    String? sessionLogId,
  }) {
    return SessionCompleteViewData(
      sourceId: sourceId,
      displayName: displayName,
      totalDurationSeconds: totalDurationSeconds,
      trainingSeconds: breakdown.trainingSeconds,
      restSeconds: breakdown.restSeconds,
      estimatedKcal: estimatedKcal,
      currentStreakDays: currentStreakDays,
      setsCount: setsCount,
      sessionLogId: sessionLogId,
    );
  }
}

/// Visual style of a share template (F16 share studio).
enum ShareTemplateStyle {
  /// Checkerboard "transparent" card; optional photo behind stats.
  transparent,

  /// Solid dark card without photo slot.
  solidDark,

  /// Solid brand/primary gradient card.
  solidBrand,
}

/// Payload for the share card image (F16 R6 + studio).
class ShareCardData {
  const ShareCardData({
    required this.displayName,
    required this.totalDurationSeconds,
    required this.trainingSeconds,
    required this.restSeconds,
    required this.setsCount,
    required this.estimatedKcal,
    required this.currentStreakDays,
    this.photoPath,
    this.template = ShareTemplateStyle.transparent,
  });

  final String displayName;
  final int totalDurationSeconds;
  final int trainingSeconds;
  final int restSeconds;
  final int setsCount;
  final int estimatedKcal;
  final int currentStreakDays;
  final String? photoPath;
  final ShareTemplateStyle template;

  factory ShareCardData.fromView(
    SessionCompleteViewData view, {
    String? photoPath,
    ShareTemplateStyle template = ShareTemplateStyle.transparent,
  }) {
    return ShareCardData(
      displayName: view.displayName,
      totalDurationSeconds: view.totalDurationSeconds,
      trainingSeconds: view.trainingSeconds,
      restSeconds: view.restSeconds,
      setsCount: view.setsCount,
      estimatedKcal: view.estimatedKcal,
      currentStreakDays: view.currentStreakDays,
      photoPath: photoPath,
      template: template,
    );
  }

  ShareCardData copyWith({
    String? photoPath,
    ShareTemplateStyle? template,
    bool clearPhoto = false,
  }) {
    return ShareCardData(
      displayName: displayName,
      totalDurationSeconds: totalDurationSeconds,
      trainingSeconds: trainingSeconds,
      restSeconds: restSeconds,
      setsCount: setsCount,
      estimatedKcal: estimatedKcal,
      currentStreakDays: currentStreakDays,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      template: template ?? this.template,
    );
  }
}

/// Result of opening the system share sheet.
enum ShareOutcome { success, dismissed, unavailable, failed }

/// UI/controller state for F16.
class SessionSummaryState {
  const SessionSummaryState({
    this.viewData,
    this.noteDraft = '',
    this.isSharing = false,
    this.isFinishing = false,
    this.shareError = false,
    this.noteError = false,
    this.noteSaveFailed = false,
    this.logResolveTimedOut = false,
    this.discardNoteOnNextDone = false,
  });

  final SessionCompleteViewData? viewData;
  final String noteDraft;
  final bool isSharing;
  final bool isFinishing;
  final bool shareError;
  final bool noteError;
  final bool noteSaveFailed;
  final bool logResolveTimedOut;

  /// After a failed note save, next Listo skips note persistence.
  final bool discardNoteOnNextDone;

  static const initial = SessionSummaryState();

  bool get isReady => viewData != null;

  bool get hasDirtyNote {
    final draft = noteDraft.trim();
    return draft.isNotEmpty;
  }

  SessionSummaryState copyWith({
    SessionCompleteViewData? viewData,
    String? noteDraft,
    bool? isSharing,
    bool? isFinishing,
    bool? shareError,
    bool? noteError,
    bool? noteSaveFailed,
    bool? logResolveTimedOut,
    bool? discardNoteOnNextDone,
  }) {
    return SessionSummaryState(
      viewData: viewData ?? this.viewData,
      noteDraft: noteDraft ?? this.noteDraft,
      isSharing: isSharing ?? this.isSharing,
      isFinishing: isFinishing ?? this.isFinishing,
      shareError: shareError ?? this.shareError,
      noteError: noteError ?? this.noteError,
      noteSaveFailed: noteSaveFailed ?? this.noteSaveFailed,
      logResolveTimedOut: logResolveTimedOut ?? this.logResolveTimedOut,
      discardNoteOnNextDone:
          discardNoteOnNextDone ?? this.discardNoteOnNextDone,
    );
  }
}

/// Max note length (same as F04).
const kSessionNoteMaxLength = 500;

/// Clamp or validate note length. Returns null if too long when [strict].
String? sanitizeNoteDraft(String raw, {bool strict = true}) {
  if (raw.length > kSessionNoteMaxLength) {
    if (strict) return null;
    return raw.substring(0, kSessionNoteMaxLength);
  }
  return raw;
}
