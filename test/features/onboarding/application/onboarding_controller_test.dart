import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/onboarding/application/onboarding_controller.dart';
import 'package:interval_timer/features/onboarding/application/onboarding_providers.dart';
import 'package:interval_timer/features/onboarding/domain/onboarding_slide_data.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository repo;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PreferencesRepository(db);
    container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('Onboarding Domain & Providers (F30)', () {
    test('defaultSlides provides exactly 3 configured slides in logical order', () {
      final slides = container.read(onboardingSlidesProvider);
      expect(slides.length, 3);
      expect(slides[0].type, OnboardingSlideType.timer);
      expect(slides[1].type, OnboardingSlideType.audio);
      expect(slides[2].type, OnboardingSlideType.progress);
      expect(slides[2].primaryActionLabel, '¡Empezar a entrenar!');
    });

    test('onboardingCurrentPageProvider starts at 0 and allows updates', () {
      expect(container.read(onboardingCurrentPageProvider), 0);
      container.read(onboardingCurrentPageProvider.notifier).state = 1;
      expect(container.read(onboardingCurrentPageProvider), 1);
    });

    test('hasSeenOnboardingProvider reflects updates from repository', () async {
      expect(await container.read(hasSeenOnboardingProvider.future), isFalse);

      await repo.setHasSeenOnboarding(true);
      container.invalidate(hasSeenOnboardingProvider);

      expect(await container.read(hasSeenOnboardingProvider.future), isTrue);
    });
  });

  group('OnboardingController (F30)', () {
    test('completeOnboarding sets hasSeenOnboarding to true in repository', () async {
      expect(await repo.hasSeenOnboarding(), isFalse);

      final controller = container.read(onboardingControllerProvider.notifier);
      await controller.completeOnboarding();

      expect(await repo.hasSeenOnboarding(), isTrue);
    });

    test('skipOnboarding sets hasSeenOnboarding to true in repository', () async {
      expect(await repo.hasSeenOnboarding(), isFalse);

      final controller = container.read(onboardingControllerProvider.notifier);
      await controller.skipOnboarding();

      expect(await repo.hasSeenOnboarding(), isTrue);
    });
  });
}
