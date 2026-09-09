import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/achievements/application/achievements_providers.dart';
import 'package:interval_timer/features/achievements/domain/achievement_def.dart';
import 'package:interval_timer/features/achievements/presentation/achievements_unlocked_sheet.dart';
import 'package:interval_timer/features/session_summary/application/session_summary_providers.dart';
import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';
import 'package:interval_timer/features/session_summary/presentation/animated_flame_hero.dart';
import 'package:interval_timer/features/session_summary/presentation/session_metric_tile.dart';
import 'package:interval_timer/features/session_summary/presentation/session_share_studio_screen.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';

/// Full post-completion celebration screen (F16 — fulfills F01 R18 UI).
///
/// 1) Centered flame + pulse rings
/// 2) After intro animation, bottom sheet (~50%) slides up with stats / share / note
/// 3) Sheet is draggable upward for more detail
class SessionCompleteScreen extends ConsumerStatefulWidget {
  const SessionCompleteScreen({super.key});

  @override
  ConsumerState<SessionCompleteScreen> createState() =>
      _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends ConsumerState<SessionCompleteScreen>
    with TickerProviderStateMixin {
  final _noteController = TextEditingController();
  final _sheetScrollController = DraggableScrollableController();

  late final AnimationController _ringController;
  late final AnimationController _sheetRevealController;
  late final Animation<Offset> _sheetSlide;

  bool _sheetVisible = false;

  static const _introMs = 1400;
  static const _sheetInitial = 0.50;
  static const _sheetMin = 0.50;
  static const _sheetMax = 0.92;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _sheetRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _sheetRevealController,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(sessionSummaryControllerProvider.notifier);
      await notifier.bootstrap();
      if (!mounted) return;
      final draft = ref.read(sessionSummaryControllerProvider).noteDraft;
      if (_noteController.text != draft) {
        _noteController.text = draft;
      }
      await Future<void>.delayed(const Duration(milliseconds: _introMs));
      if (!mounted) return;
      setState(() => _sheetVisible = true);
      await _sheetRevealController.forward();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _ringController.dispose();
    _sheetRevealController.dispose();
    _sheetScrollController.dispose();
    super.dispose();
  }

  Future<void> _openShareStudio(SessionCompleteViewData view) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SessionShareStudioScreen(viewData: view),
      ),
    );
  }

  Future<void> _onDone() async {
    final messenger = ScaffoldMessenger.of(context);
    final pending = List<AchievementDef>.from(
      ref.read(pendingUnlockCelebrationProvider),
    );
    final ok =
        await ref.read(sessionSummaryControllerProvider.notifier).finish();
    if (!mounted) return;
    if (!ok) {
      final failed =
          ref.read(sessionSummaryControllerProvider).noteSaveFailed;
      if (failed) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(context.l10n.sessionSummaryNoteSaveFailed),
            action: SnackBarAction(
              label: context.l10n.sessionSummaryDoneAnyway,
              onPressed: () async {
                final left = await ref
                    .read(sessionSummaryControllerProvider.notifier)
                    .finishDiscardingNote();
                if (!left || !mounted) return;
                await _leaveAfterDone(pending);
              },
            ),
          ),
        );
      }
      return;
    }
    await _leaveAfterDone(pending);
  }

  /// Shows F13 multi-unlock sheet (if any) then returns to home (R7).
  Future<void> _leaveAfterDone(List<AchievementDef> pending) async {
    if (pending.isNotEmpty && mounted) {
      await showAchievementsUnlockedSheet(
        context: context,
        unlocked: pending,
        onClosed: () {
          ref.read(achievementsControllerProvider.notifier).clearPendingCelebration();
        },
      );
    } else {
      ref.read(achievementsControllerProvider.notifier).clearPendingCelebration();
    }
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionSummaryControllerProvider);
    final view = state.viewData;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primary,
              Color.lerp(primary, Colors.black, 0.18)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Phase 1: full-center flame. After sheet: center of the UPPER 50%.
            // Alignment y=-0.5 is the vertical midpoint of the top half.
            Align(
              alignment: _sheetVisible
                  ? const Alignment(0, -0.5)
                  : Alignment.center,
              child: AnimatedFlameHero(
                animation: _ringController,
                size: _sheetVisible ? 100 : 128,
              ),
            ),
            // Phase 2: draggable info sheet from bottom (~50% initial).
            if (_sheetVisible)
              SlideTransition(
                position: _sheetSlide,
                child: DraggableScrollableSheet(
                  controller: _sheetScrollController,
                  initialChildSize: _sheetInitial,
                  minChildSize: _sheetMin,
                  maxChildSize: _sheetMax,
                  snap: true,
                  snapSizes: const [_sheetInitial, 0.75, _sheetMax],
                  builder: (context, scrollController) {
                    return Material(
                      elevation: 12,
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusXl),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: view == null
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                const SizedBox(height: AppTheme.spacingSm),
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.outlineVariant,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    padding: const EdgeInsets.fromLTRB(
                                      AppTheme.spacingLg,
                                      AppTheme.spacingMd,
                                      AppTheme.spacingLg,
                                      AppTheme.spacingSm,
                                    ),
                                    children: [
                                      Text(
                                        context.l10n.sessionSummaryGreatJob,
                                        key: const Key(
                                          'session_completed_title',
                                        ),
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppTheme.spacingSm,
                                      ),
                                      // F13: non-destructive chip for pending unlocks (R7)
                                      Consumer(
                                        builder: (context, ref, _) {
                                          final pending = ref.watch(
                                            pendingUnlockCelebrationProvider,
                                          );
                                          if (pending.isEmpty) {
                                            return const SizedBox.shrink();
                                          }
                                          final label = pending.length == 1
                                              ? context.l10n
                                                  .sessionSummaryNewAchievementsOne
                                              : context.l10n
                                                  .sessionSummaryNewAchievementsMany(
                                                    pending.length,
                                                  );
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: AppTheme.spacingMd,
                                            ),
                                            child: ActionChip(
                                              key: const Key(
                                                'session_summary_achievements_chip',
                                              ),
                                              avatar: Icon(
                                                Icons.emoji_events_rounded,
                                                color: theme.colorScheme.primary,
                                                size: 18,
                                              ),
                                              label: Text(label),
                                              onPressed: () {
                                                showAchievementsUnlockedSheet(
                                                  context: context,
                                                  unlocked: pending,
                                                  onClosed: () {
                                                    ref
                                                        .read(
                                                          achievementsControllerProvider
                                                              .notifier,
                                                        )
                                                        .clearPendingCelebration();
                                                  },
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SessionMetricTile(
                                              key: const Key(
                                                'session_metric_training',
                                              ),
                                              seconds: view.trainingSeconds,
                                              label: context.l10n
                                                  .sessionSummaryTraining,
                                              accent: AppTheme.workColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: AppTheme.spacingMd,
                                          ),
                                          Expanded(
                                            child: SessionMetricTile(
                                              key: const Key(
                                                'session_metric_rest',
                                              ),
                                              seconds: view.restSeconds,
                                              label: context.l10n
                                                  .sessionSummaryRest,
                                              accent: AppTheme.restColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: AppTheme.spacingMd,
                                      ),
                                      Text(
                                        context.l10n.sessionSummaryNotePrompt,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppTheme.spacingSm,
                                      ),
                                      TextField(
                                        key: const Key(
                                          'session_summary_note_field',
                                        ),
                                        controller: _noteController,
                                        enabled: view.noteEnabled &&
                                            !state.isFinishing,
                                        maxLength: kSessionNoteMaxLength,
                                        maxLines: 3,
                                        minLines: 2,
                                        onChanged: (v) => ref
                                            .read(
                                              sessionSummaryControllerProvider
                                                  .notifier,
                                            )
                                            .updateNoteDraft(v),
                                        decoration: InputDecoration(
                                          hintText: view.noteEnabled
                                              ? context.l10n.historyAddNote
                                              : context.l10n
                                                  .sessionSummaryNoteUnavailable,
                                          errorText: state.noteError
                                              ? context.l10n
                                                  .sessionSummaryNoteSaveFailed
                                              : null,
                                        ),
                                      ),
                                      if (state.logResolveTimedOut &&
                                          !view.noteEnabled)
                                        Text(
                                          context.l10n
                                              .sessionSummaryNoteUnavailable,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      const SizedBox(
                                        height: AppTheme.spacingMd,
                                      ),
                                      Text(
                                        context.l10n.sessionSummarySheetHint,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Sticky actions always reachable at ~50% sheet.
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppTheme.spacingLg,
                                    AppTheme.spacingSm,
                                    AppTheme.spacingLg,
                                    AppTheme.spacingSm,
                                  ),
                                  child: Column(
                                    children: [
                                      AppPrimaryButton(
                                        key: const Key(
                                          'session_summary_share_button',
                                        ),
                                        expand: true,
                                        onPressed: () =>
                                            _openShareStudio(view),
                                        label: context.l10n.sessionSummaryShare,
                                        icon: Icons.ios_share_rounded,
                                      ),
                                      const SizedBox(
                                        height: AppTheme.spacingSm,
                                      ),
                                      AppPrimaryButton(
                                        key: const Key(
                                          'back_to_routine_button',
                                        ),
                                        expand: true,
                                        onPressed: state.isFinishing
                                            ? null
                                            : _onDone,
                                        label: context.l10n.sessionSummaryDone,
                                        icon: Icons.check_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.paddingOf(context).bottom +
                                          AppTheme.spacingSm,
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
