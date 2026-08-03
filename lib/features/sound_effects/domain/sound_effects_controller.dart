import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/features/sound_effects/domain/remaining_seconds.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_catalog.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_player.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_slot.dart';
import 'package:interval_timer/features/sound_effects/domain/sound_effects_settings.dart';
import 'package:interval_timer/features/timer/application/timer_session_events.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

/// Domain service: reacts to F01/F35 timer events and plays packaged SFX.
///
/// Does not mutate timer state or voice/vibration prefs. Failures are silent (R12).
class SoundEffectsController {
  SoundEffectsController(
    this._player, {
    SoundEffectsSettings? settings,
    this.catalog = const SfxCatalog(),
  }) : _settings = settings ?? SoundEffectsSettings.defaults;

  final SfxPlayer _player;
  final SfxCatalog catalog;
  SoundEffectsSettings _settings;

  final Set<int> _prepTickedSeconds = <int>{};
  final Set<int> _warnedSecondsForInterval = <int>{};
  TimerStatus _lastStatus = TimerStatus.idle;

  SoundEffectsSettings get settings => _settings;

  void updateSettings(SoundEffectsSettings settings) {
    _settings = settings;
  }

  Future<void> onIntervalStarted(IntervalStartedEvent event) async {
    _warnedSecondsForInterval.clear();
    // Leaving prep: clear prep tick set so a future prep session starts clean.
    _prepTickedSeconds.clear();

    if (!_settings.soundEnabled) return;

    if (event.type == IntervalType.rest) {
      if (!_settings.soundOnRestStart) return;
      await _playSlot(SfxSlot.restStart);
    } else {
      if (!_settings.soundOnWorkStart) return;
      await _playSlot(SfxSlot.workStart);
    }
  }

  /// Called on every [TimerState] change (remainingMs / status).
  Future<void> onTimerState(TimerState state) async {
    final status = state.status;

    if (status == TimerStatus.paused) {
      _lastStatus = status;
      return;
    }

    if (status == TimerStatus.idle) {
      if (_lastStatus != status) {
        _prepTickedSeconds.clear();
        _warnedSecondsForInterval.clear();
      }
      _lastStatus = status;
      return;
    }

    if (status == TimerStatus.completed) {
      // Session-complete SFX is handled via [onSessionCompleted] stream.
      if (_lastStatus != status) {
        _prepTickedSeconds.clear();
        _warnedSecondsForInterval.clear();
      }
      _lastStatus = status;
      return;
    }

    // Fresh prep session after idle/completed.
    if (status == TimerStatus.preparing &&
        (_lastStatus == TimerStatus.idle ||
            _lastStatus == TimerStatus.completed)) {
      _prepTickedSeconds.clear();
    }

    _lastStatus = status;

    if (status == TimerStatus.preparing) {
      await _maybePrepTick(state);
      return;
    }

    if (status == TimerStatus.running &&
        state.segmentKind == SegmentKind.interval) {
      await _maybePhaseWarning(state);
    }
  }

  Future<void> onSessionCompleted() async {
    _prepTickedSeconds.clear();
    _warnedSecondsForInterval.clear();
    _lastStatus = TimerStatus.completed;

    if (!_settings.soundEnabled) return;
    if (!_settings.soundOnSessionComplete) return;
    await _playSlot(SfxSlot.sessionComplete);
  }

  Future<void> onSessionCancelled() async {
    _prepTickedSeconds.clear();
    _warnedSecondsForInterval.clear();
    _lastStatus = TimerStatus.idle;
  }

  /// Preview a catalog id from Settings (always available; ignores master mute).
  Future<void> previewSoundId(String soundId) async {
    final entry = catalog.resolve(soundId);
    if (entry == null) return;
    try {
      await _player.playAsset(entry.assetSourcePath);
    } catch (_) {}
  }

  Future<void> _maybePrepTick(TimerState state) async {
    if (!_settings.soundEnabled) return;
    if (!_settings.soundOnPrepTick) return;

    final s = remainingSecondsCeil(state.remainingMs);
    if (s < 1) return;
    if (_prepTickedSeconds.contains(s)) return;

    _prepTickedSeconds.add(s);
    await _playSlot(SfxSlot.prepTick);
  }

  Future<void> _maybePhaseWarning(TimerState state) async {
    if (!_settings.soundEnabled) return;
    if (!_settings.soundOnPhaseWarning) return;
    if (_settings.soundCountdownSeconds <= 0) return;

    final s = remainingSecondsCeil(state.remainingMs);
    if (s < 1 || s > _settings.soundCountdownSeconds) return;
    if (_warnedSecondsForInterval.contains(s)) return;

    _warnedSecondsForInterval.add(s);
    await _playSlot(SfxSlot.phaseWarning);
  }

  Future<void> _playSlot(SfxSlot slot) async {
    final preferredId = _settings.soundIdFor(slot);
    final entry = catalog.resolveOrDefault(preferredId, slot);
    try {
      await _player.playAsset(entry.assetSourcePath);
    } catch (_) {
      // R12
    }
  }
}
