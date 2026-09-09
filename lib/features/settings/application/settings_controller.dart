import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/body_tracking/application/body_tracking_providers.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_language.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    final prep = await repo.getPrepSeconds();
    final voiceEnabled = await repo.getVoiceEnabled();
    final countdownSeconds = await repo.getCountdownSeconds();
    final announceIntervalName = await repo.getAnnounceIntervalName();
    final musicDuckingEnabled = await repo.getMusicDuckingEnabled();
    final vibrationEnabled = await repo.getVibrationEnabled();
    final vibrationOnIntervalStart = await repo.getVibrationOnIntervalStart();
    final vibrationOnCountdown = await repo.getVibrationOnCountdown();
    final vibrationCountdownSeconds =
        await repo.getVibrationCountdownSeconds();
    final soundEnabled = await repo.getSoundEnabled();
    final soundOnWorkStart = await repo.getSoundOnWorkStart();
    final soundOnRestStart = await repo.getSoundOnRestStart();
    final soundOnSessionComplete = await repo.getSoundOnSessionComplete();
    final soundOnPrepTick = await repo.getSoundOnPrepTick();
    final soundOnPhaseWarning = await repo.getSoundOnPhaseWarning();
    final soundCountdownSeconds = await repo.getSoundCountdownSeconds();
    final soundIdWorkStart = await repo.getSoundIdWorkStart();
    final soundIdRestStart = await repo.getSoundIdRestStart();
    final soundIdSessionComplete = await repo.getSoundIdSessionComplete();
    final soundIdPrepTick = await repo.getSoundIdPrepTick();
    final soundIdPhaseWarning = await repo.getSoundIdPhaseWarning();
    final keepScreenOnEnabled = await repo.getKeepScreenOnEnabled();
    final sessionLockScreenEnabled = await repo.getSessionLockScreenEnabled();
    final themeMode = await repo.getThemeMode();
    final bodyWeightUnit = await repo.getBodyWeightUnit();
    final appLanguage = await repo.getAppLanguage();
    return AppSettings(
      prepSeconds: prep,
      voiceEnabled: voiceEnabled,
      countdownSeconds: countdownSeconds,
      announceIntervalName: announceIntervalName,
      musicDuckingEnabled: musicDuckingEnabled,
      vibrationEnabled: vibrationEnabled,
      vibrationOnIntervalStart: vibrationOnIntervalStart,
      vibrationOnCountdown: vibrationOnCountdown,
      vibrationCountdownSeconds: vibrationCountdownSeconds,
      soundEnabled: soundEnabled,
      soundOnWorkStart: soundOnWorkStart,
      soundOnRestStart: soundOnRestStart,
      soundOnSessionComplete: soundOnSessionComplete,
      soundOnPrepTick: soundOnPrepTick,
      soundOnPhaseWarning: soundOnPhaseWarning,
      soundCountdownSeconds: soundCountdownSeconds,
      soundIdWorkStart: soundIdWorkStart,
      soundIdRestStart: soundIdRestStart,
      soundIdSessionComplete: soundIdSessionComplete,
      soundIdPrepTick: soundIdPrepTick,
      soundIdPhaseWarning: soundIdPhaseWarning,
      keepScreenOnEnabled: keepScreenOnEnabled,
      sessionLockScreenEnabled: sessionLockScreenEnabled,
      themeMode: themeMode,
      bodyWeightUnit: bodyWeightUnit,
      appLanguage: appLanguage,
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

  Future<void> setMusicDuckingEnabled(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setMusicDuckingEnabled(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(musicDuckingEnabled: value));
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

  Future<void> setSoundEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setSoundEnabled(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundEnabled: value));
  }

  Future<void> setSoundOnWorkStart(bool value) async {
    await ref.read(settingsRepositoryProvider).setSoundOnWorkStart(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundOnWorkStart: value));
  }

  Future<void> setSoundOnRestStart(bool value) async {
    await ref.read(settingsRepositoryProvider).setSoundOnRestStart(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundOnRestStart: value));
  }

  Future<void> setSoundOnSessionComplete(bool value) async {
    await ref.read(settingsRepositoryProvider).setSoundOnSessionComplete(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundOnSessionComplete: value));
  }

  Future<void> setSoundOnPrepTick(bool value) async {
    await ref.read(settingsRepositoryProvider).setSoundOnPrepTick(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundOnPrepTick: value));
  }

  Future<void> setSoundOnPhaseWarning(bool value) async {
    await ref.read(settingsRepositoryProvider).setSoundOnPhaseWarning(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundOnPhaseWarning: value));
  }

  Future<void> setSoundCountdownSeconds(int value) async {
    final clamped = value.clamp(
      SettingsRepository.minSoundCountdownSeconds,
      SettingsRepository.maxSoundCountdownSeconds,
    );
    await ref
        .read(settingsRepositoryProvider)
        .setSoundCountdownSeconds(clamped);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundCountdownSeconds: clamped));
  }

  Future<void> setSoundIdWorkStart(String value) async {
    await ref.read(settingsRepositoryProvider).setSoundIdWorkStart(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundIdWorkStart: value));
  }

  Future<void> setSoundIdRestStart(String value) async {
    await ref.read(settingsRepositoryProvider).setSoundIdRestStart(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundIdRestStart: value));
  }

  Future<void> setSoundIdSessionComplete(String value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setSoundIdSessionComplete(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundIdSessionComplete: value));
  }

  Future<void> setSoundIdPrepTick(String value) async {
    await ref.read(settingsRepositoryProvider).setSoundIdPrepTick(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundIdPrepTick: value));
  }

  Future<void> setSoundIdPhaseWarning(String value) async {
    await ref.read(settingsRepositoryProvider).setSoundIdPhaseWarning(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(soundIdPhaseWarning: value));
  }

  Future<void> setKeepScreenOnEnabled(bool value) async {
    await ref.read(settingsRepositoryProvider).setKeepScreenOnEnabled(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(keepScreenOnEnabled: value));
  }

  Future<void> setSessionLockScreenEnabled(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setSessionLockScreenEnabled(value);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(sessionLockScreenEnabled: value));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await ref.read(settingsRepositoryProvider).setThemeMode(mode);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(themeMode: mode));
  }

  Future<void> setBodyWeightUnit(BodyWeightUnit unit) async {
    await ref.read(settingsRepositoryProvider).setBodyWeightUnit(unit);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(bodyWeightUnit: unit));
    // Keep body-tracking unit provider in sync for form/chart labels.
    ref.invalidate(bodyWeightUnitProvider);
  }

  Future<void> setAppLanguage(AppLanguage language) async {
    await ref.read(settingsRepositoryProvider).setAppLanguage(language);
    final current =
        state.valueOrNull ?? const AppSettings(prepSeconds: 10);
    state = AsyncData(current.copyWith(appLanguage: language));
  }
}
