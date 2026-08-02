import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/features/sound_effects/domain/no_op_sfx_player.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_catalog.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_player.dart';
import 'package:interval_timer/features/sound_effects/domain/sound_effects_controller.dart';
import 'package:interval_timer/features/sound_effects/domain/sound_effects_settings.dart';
import 'package:interval_timer/features/timer/application/timer_session_events.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';

/// Records plays without cancelling previous ones (overlap-friendly fake).
class FakeSfxPlayer implements SfxPlayer {
  final List<String> plays = <String>[];
  bool throwOnPlay = false;

  @override
  Future<void> playAsset(String assetSourcePath) async {
    if (throwOnPlay) throw Exception('play failed');
    plays.add(assetSourcePath);
  }

  @override
  Future<void> dispose() async {}
}

IntervalStartedEvent _started({
  String id = 'i1',
  String name = 'Work',
  int durationSeconds = 10,
  int index = 0,
  IntervalType type = IntervalType.work,
}) {
  return IntervalStartedEvent(
    intervalId: id,
    name: name,
    announceText: null,
    durationSeconds: durationSeconds,
    index: index,
    type: type,
  );
}

TimerState _state({
  required int remainingMs,
  TimerStatus status = TimerStatus.running,
  SegmentKind segmentKind = SegmentKind.interval,
}) {
  return TimerState(
    status: status,
    remainingMs: remainingMs,
    currentIntervalDurationMs: remainingMs > 0 ? remainingMs : 1000,
    segmentKind: segmentKind,
  );
}

void main() {
  const catalog = SfxCatalog();
  const workPath = 'sfx/default/sfx_work_start_01.mp3';
  const restPath = 'sfx/default/sfx_rest_start_01.wav';
  const completePath = 'sfx/default/sfx_session_complete_01.wav';
  const tickPath = 'sfx/default/sfx_tick_01.wav';

  group('SoundEffectsController happy path', () {
    test('work and warmup play work_start', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(player, catalog: catalog);

      await controller.onIntervalStarted(_started(type: IntervalType.work));
      await controller.onIntervalStarted(
        _started(id: 'i2', type: IntervalType.warmup),
      );

      expect(player.plays, [workPath, workPath]);
    });

    test('rest interval plays rest_start', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(player, catalog: catalog);

      await controller.onIntervalStarted(_started(type: IntervalType.rest));

      expect(player.plays, [restPath]);
    });

    test('session completed plays complete', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(player, catalog: catalog);

      await controller.onSessionCompleted();

      expect(player.plays, [completePath]);
    });

    test('session cancelled does not play complete', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(player, catalog: catalog);

      await controller.onSessionCancelled();

      expect(player.plays, isEmpty);
    });
  });

  group('prep ticks', () {
    test('prep S=3,2,1 each once', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(
        player,
        catalog: catalog,
        settings: const SoundEffectsSettings(soundOnWorkStart: false),
      );

      await controller.onTimerState(
        _state(
          remainingMs: 3000,
          status: TimerStatus.preparing,
          segmentKind: SegmentKind.preparation,
        ),
      );
      await controller.onTimerState(
        _state(
          remainingMs: 2900,
          status: TimerStatus.preparing,
          segmentKind: SegmentKind.preparation,
        ),
      );
      await controller.onTimerState(
        _state(
          remainingMs: 2000,
          status: TimerStatus.preparing,
          segmentKind: SegmentKind.preparation,
        ),
      );
      await controller.onTimerState(
        _state(
          remainingMs: 1000,
          status: TimerStatus.preparing,
          segmentKind: SegmentKind.preparation,
        ),
      );

      expect(player.plays.length, 3);
      expect(player.plays.every((p) => p == tickPath), isTrue);
    });
  });

  group('phase warning', () {
    test('N=3 plays at S=3,2,1; N=0 plays none', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(
        player,
        catalog: catalog,
        settings: const SoundEffectsSettings(
          soundOnWorkStart: false,
          soundCountdownSeconds: 3,
        ),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(_state(remainingMs: 3000));
      await controller.onTimerState(_state(remainingMs: 2900));
      await controller.onTimerState(_state(remainingMs: 2000));
      await controller.onTimerState(_state(remainingMs: 1000));

      expect(player.plays.length, 3);
      expect(player.plays.every((p) => p == tickPath), isTrue);

      final player2 = FakeSfxPlayer();
      final controller2 = SoundEffectsController(
        player2,
        catalog: catalog,
        settings: const SoundEffectsSettings(
          soundOnWorkStart: false,
          soundCountdownSeconds: 0,
        ),
      );
      await controller2.onIntervalStarted(_started());
      await controller2.onTimerState(_state(remainingMs: 3000));
      expect(player2.plays, isEmpty);
    });
  });

  group('toggles and master', () {
    test('master off omits all', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(
        player,
        catalog: catalog,
        settings: const SoundEffectsSettings(soundEnabled: false),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(
        _state(
          remainingMs: 2000,
          status: TimerStatus.preparing,
          segmentKind: SegmentKind.preparation,
        ),
      );
      await controller.onSessionCompleted();

      expect(player.plays, isEmpty);
    });

    test('granular toggles omit only their event', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(
        player,
        catalog: catalog,
        settings: const SoundEffectsSettings(
          soundOnWorkStart: false,
          soundOnRestStart: true,
          soundOnSessionComplete: false,
          soundOnPrepTick: false,
          soundOnPhaseWarning: false,
        ),
      );

      await controller.onIntervalStarted(_started(type: IntervalType.work));
      await controller.onIntervalStarted(_started(type: IntervalType.rest));
      await controller.onSessionCompleted();

      expect(player.plays, [restPath]);
    });
  });

  group('edge cases', () {
    test('player throw does not propagate', () async {
      final player = FakeSfxPlayer()..throwOnPlay = true;
      final controller = SoundEffectsController(player, catalog: catalog);

      await controller.onIntervalStarted(_started());
    });

    test('invalid sound id falls back to default', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(
        player,
        catalog: catalog,
        settings: const SoundEffectsSettings(
          soundIdWorkStart: 'does_not_exist',
        ),
      );

      await controller.onIntervalStarted(_started());

      expect(player.plays, [workPath]);
    });

    test('pause suppresses new ticks; resume does not re-fire same S', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(
        player,
        catalog: catalog,
        settings: const SoundEffectsSettings(soundOnWorkStart: false),
      );

      await controller.onIntervalStarted(_started());
      await controller.onTimerState(_state(remainingMs: 3000));
      expect(player.plays.length, 1);

      await controller.onTimerState(
        _state(remainingMs: 3000, status: TimerStatus.paused),
      );
      await controller.onTimerState(_state(remainingMs: 3000));
      expect(player.plays.length, 1);

      await controller.onTimerState(_state(remainingMs: 2000));
      expect(player.plays.length, 2);
    });

    test('idle does not play phase SFX', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(player, catalog: catalog);

      await controller.onTimerState(
        _state(remainingMs: 2000, status: TimerStatus.idle),
      );

      expect(player.plays, isEmpty);
    });

    test('overlap: consecutive plays both recorded', () async {
      final player = FakeSfxPlayer();
      final controller = SoundEffectsController(player, catalog: catalog);

      await controller.onIntervalStarted(_started(type: IntervalType.work));
      await controller.onIntervalStarted(_started(type: IntervalType.rest));

      expect(player.plays, [workPath, restPath]);
    });

    test('preview plays catalog path', () async {
      final player = NoOpSfxPlayer();
      final controller = SoundEffectsController(player, catalog: catalog);

      await controller.previewSoundId(SfxCatalog.defaultPrepTickId);

      expect(player.plays, [tickPath]);
    });
  });
}
