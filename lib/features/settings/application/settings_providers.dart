import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/settings/application/settings_controller.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(preferencesRepositoryProvider));
});

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
