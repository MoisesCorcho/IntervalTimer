import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider reflecting the application's current OS lifecycle state.
final appLifecycleStateProvider = StateProvider<AppLifecycleState>((ref) {
  try {
    return WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  } catch (_) {
    return AppLifecycleState.resumed;
  }
});

/// Pure derived provider indicating if the app is currently in the background
/// (inactive, paused, or hidden).
final isAppInBackgroundProvider = Provider<bool>((ref) {
  final state = ref.watch(appLifecycleStateProvider);
  return state == AppLifecycleState.paused ||
      state == AppLifecycleState.hidden ||
      state == AppLifecycleState.inactive;
});
