import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/onboarding/application/onboarding_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

class OnboardingController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Marks the onboarding as completed and refreshes the reactive stream provider.
  Future<void> completeOnboarding() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(preferencesRepositoryProvider);
      await repo.setHasSeenOnboarding(true);
      ref.invalidate(hasSeenOnboardingProvider);
    });
  }

  /// Skips the onboarding directly to workout presets.
  Future<void> skipOnboarding() => completeOnboarding();
}

final onboardingControllerProvider =
    AutoDisposeAsyncNotifierProvider<OnboardingController, void>(
  OnboardingController.new,
);
