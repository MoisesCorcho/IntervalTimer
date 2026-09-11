import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/onboarding/domain/onboarding_slide_data.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

/// Exposes whether the user has completed or skipped the onboarding flow.
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(preferencesRepositoryProvider);
  return repo.hasSeenOnboarding();
});

/// Exposes the static curated slides of the onboarding flow.
final onboardingSlidesProvider = Provider<List<OnboardingSlideData>>((ref) {
  return OnboardingSlideData.defaultSlides;
});

/// Tracks the active slide index in the onboarding PageView.
final onboardingCurrentPageProvider = StateProvider<int>((ref) => 0);
