import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prep = await ref.watch(settingsRepositoryProvider).getPrepSeconds();
    return AppSettings(prepSeconds: prep);
  }

  Future<void> setPrepSeconds(int value) async {
    final clamped = value.clamp(
      SettingsRepository.minPrepSeconds,
      SettingsRepository.maxPrepSeconds,
    );
    await ref.read(settingsRepositoryProvider).setPrepSeconds(clamped);
    state = AsyncData(AppSettings(prepSeconds: clamped));
  }
}
