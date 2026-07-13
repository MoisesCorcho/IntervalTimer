import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/app/app_shell.dart';
import 'package:interval_timer/features/calendar_history/presentation/history_screen.dart';
import 'package:interval_timer/features/settings/presentation/settings_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/timer/presentation/routine_editor_screen.dart';
import 'package:interval_timer/features/timer/presentation/session_completed_screen.dart';
import 'package:interval_timer/features/timer/presentation/timer_execution_screen.dart';
import 'package:interval_timer/features/workout_builder/presentation/my_workouts_screen.dart';
import 'package:interval_timer/features/workout_builder/presentation/workout_editor_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorRoutineKey =
    GlobalKey<NavigatorState>(debugLabel: 'routine');
final _shellNavigatorWorkoutsKey =
    GlobalKey<NavigatorState>(debugLabel: 'workouts');
final _shellNavigatorHistoryKey =
    GlobalKey<NavigatorState>(debugLabel: 'history');
final _shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final timerStatus = ref.read(timerControllerProvider).status;
      final location = state.matchedLocation;

      if (timerStatus == TimerStatus.running ||
          timerStatus == TimerStatus.paused ||
          timerStatus == TimerStatus.preparing) {
        if (location != '/execute') return '/execute';
      }

      if (timerStatus == TimerStatus.completed) {
        if (location != '/completed') return '/completed';
      }

      if (timerStatus == TimerStatus.idle) {
        if (location == '/execute' || location == '/completed') {
          return '/';
        }
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorRoutineKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const RoutineEditorScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorWorkoutsKey,
            routes: [
              GoRoute(
                path: '/workouts',
                builder: (context, state) => const MyWorkoutsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHistoryKey,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/workouts/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkoutEditorScreen(workoutId: id);
        },
      ),
      GoRoute(
        path: '/execute',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TimerExecutionScreen(),
      ),
      GoRoute(
        path: '/completed',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SessionCompletedScreen(),
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _ref.listen(timerControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
