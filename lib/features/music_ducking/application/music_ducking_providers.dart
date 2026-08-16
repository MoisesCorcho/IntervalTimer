import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/music_ducking/data/default_audio_session_manager.dart';
import 'package:interval_timer/features/music_ducking/domain/audio_session_manager.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';

/// Provides the singleton [AudioSessionManager] for managing platform audio focus.
final audioSessionManagerProvider = Provider<AudioSessionManager>((ref) {
  return DefaultAudioSessionManager();
});

/// Provides the current boolean preference for background music ducking (F17).
final musicDuckingEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull;
  return settings?.musicDuckingEnabled ?? true;
});
