import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/timer/presentation/routine_editor_screen.dart';
import 'package:interval_timer/features/timer/presentation/session_completed_screen.dart';
import 'package:interval_timer/features/timer/presentation/timer_execution_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
          timerStatus == TimerStatus.paused) {
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
      GoRoute(
        path: '/',
        builder: (context, state) => const RoutineEditorScreen(),
      ),
      GoRoute(
        path: '/execute',
        builder: (context, state) => const TimerExecutionScreen(),
      ),
      GoRoute(
        path: '/completed',
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