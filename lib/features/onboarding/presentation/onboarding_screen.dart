import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/onboarding/application/onboarding_controller.dart';
import 'package:interval_timer/features/onboarding/application/onboarding_providers.dart';
import 'package:interval_timer/features/onboarding/presentation/widgets/onboarding_page_indicator.dart';
import 'package:interval_timer/features/onboarding/presentation/widgets/onboarding_skip_button.dart';
import 'package:interval_timer/features/onboarding/presentation/widgets/slides/audio_showcase_slide.dart';
import 'package:interval_timer/features/onboarding/presentation/widgets/slides/progress_showcase_slide.dart';
import 'package:interval_timer/features/onboarding/presentation/widgets/slides/timer_showcase_slide.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onFinished,
  });

  /// Optional callback invoked upon completing or skipping onboarding.
  /// If omitted, defaults to navigating to `/presets` via GoRouter.
  final VoidCallback? onFinished;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const _slideWidgets = <Widget>[
    TimerShowcaseSlide(),
    AudioShowcaseSlide(),
    ProgressShowcaseSlide(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentPage = index;
    });
    ref.read(onboardingCurrentPageProvider.notifier).state = index;
  }

  Future<void> _handleNext() async {
    if (_currentPage < _slideWidgets.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      await _handleFinish();
    }
  }

  Future<void> _handleSkip() async {
    HapticFeedback.lightImpact();
    await ref.read(onboardingControllerProvider.notifier).skipOnboarding();
    _navigateNext();
  }

  Future<void> _handleFinish() async {
    HapticFeedback.mediumImpact();
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    _navigateNext();
  }

  void _navigateNext() {
    if (widget.onFinished != null) {
      widget.onFinished!();
    } else if (mounted) {
      context.go('/presets');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = _currentPage == _slideWidgets.length - 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    colorScheme.primary.withValues(alpha: 0.1),
                    const Color(0xFF121212),
                    const Color(0xFF0D0D0D),
                  ]
                : [
                    colorScheme.primary.withValues(alpha: 0.08),
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF7F7F7),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Header with Skip Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Balancing spacer
                  OnboardingSkipButton(onPressed: _handleSkip),
                ],
              ),
              // Main Interactive Slides
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: _slideWidgets,
                ),
              ),
              // Bottom Indicator and Action Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingMd,
                ),
                child: Row(
                  children: [
                    OnboardingPageIndicator(
                      currentPage: _currentPage,
                      totalPages: _slideWidgets.length,
                    ),
                    const Spacer(),
                    AppPrimaryButton(
                      label: isLastPage ? '¡Empezar a entrenar!' : 'Siguiente',
                      icon: isLastPage ? Icons.bolt : Icons.arrow_forward,
                      onPressed: _handleNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
