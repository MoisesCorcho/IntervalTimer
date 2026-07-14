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
    final vibrationEnabled = await repo.getVibrationEnabled();
    final vibrationOnIntervalStart = await repo.getVibrationOnIntervalStart();
    final vibrationOnCountdown = await repo.getVibrationOnCountdown();
    final vibrationCountdownSeconds =
        await repo.getVibrationCountdownSeconds();
    return AppSettings(
      prepSeconds: prep,
      voiceEnabled: voiceEnabled,
      countdownSeconds: countdownSeconds,
      announceIntervalName: announceIntervalName,
      vibrationEnabled: vibrationEnabled,
      vibrationOnIntervalStart: vibrationOnIntervalStart,
      vibrationOnCountdown: vibrationOnCountdown,
      vibrationCountdownSeconds: vibrationCountdownSeconds,
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

  Future<void> setVibrationEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setVibrationEnabled(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(vibrationEnabled: value));
  }

  Future<void> setVibrationOnIntervalStart(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setVibrationOnIntervalStart(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(vibrationOnIntervalStart: value));
  }

  Future<void> setVibrationOnCountdown(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setVibrationOnCountdown(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(vibrationOnCountdown: value));
  }

  Future<void> setVibrationCountdownSeconds(int value) async {
    final clamped = value.clamp(
      SettingsRepository.minVibrationCountdownSeconds,
      SettingsRepository.maxVibrationCountdownSeconds,
    );
    await ref
        .read(settingsRepositoryProvider)
        .setVibrationCountdownSeconds(clamped);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(vibrationCountdownSeconds: clamped));
  }
}
