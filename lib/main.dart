import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/app/app.dart';
import 'package:interval_timer/features/lock_screen/application/session_background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // F17 & F36: Set global audio context so SFX and timer sounds mix without taking exclusive focus
  try {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      ),
    );
  } catch (e, st) {
    debugPrint('Global AudioPlayer setAudioContext failed: $e\n$st');
  }

  // F20: register Android FGS entry-point (autoStart: false).
  // Safe no-op / soft-fail on desktop and when plugins are unavailable.
  try {
    await configureSessionBackgroundService();
  } catch (e, st) {
    debugPrint('configureSessionBackgroundService failed: $e\n$st');
  }
  runApp(const ProviderScope(child: App()));
}