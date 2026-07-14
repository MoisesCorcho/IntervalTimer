import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    final prep = await repo.getPrepSeconds();
    final voiceEnabled = await repo.getVoiceEnabled();
    final countdownSeconds = await repo.getCountdownSeconds();
    final announceIntervalName = await repo.getAnnounceIntervalName();
    return AppSettings(
      prepSeconds: prep,
      voiceEnabled: voiceEnabled,
      countdownSeconds: countdownSeconds,
      announceIntervalName: announceIntervalName,
    );
  }

  Future<void> setPrepSeconds(int value) async {
    final clamped = value.clamp(
      SettingsRepository.minPrepSeconds,
      SettingsRepository.maxPrepSeconds,
    );
    await ref.read(settingsRepositoryProvider).setPrepSeconds(clamped);
    final current = state.valueOrNull ?? AppSettings(prepSeconds: clamped);
    state = AsyncData(current.copyWith(prepSeconds: clamped));
  }

  Future<void> setVoiceEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setVoiceEnabled(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(voiceEnabled: value));
  }

  Future<void> setCountdownSeconds(int value) async {
    final clamped = value.clamp(
      SettingsRepository.minCountdownSeconds,
      SettingsRepository.maxCountdownSeconds,
    );
    await ref.read(settingsRepositoryProvider).setCountdownSeconds(clamped);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(countdownSeconds: clamped));
  }

  Future<void> setAnnounceIntervalName(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setAnnounceIntervalName(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(announceIntervalName: value));
  }
}
