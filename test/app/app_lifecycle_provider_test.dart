import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/app/app_lifecycle_provider.dart';

void main() {
  test('isAppInBackgroundProvider returns false when resumed and true when paused/hidden/inactive', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial default: resumed -> background false
    container.read(appLifecycleStateProvider.notifier).state = AppLifecycleState.resumed;
    expect(container.read(isAppInBackgroundProvider), isFalse);

    // Inactive -> background true
    container.read(appLifecycleStateProvider.notifier).state = AppLifecycleState.inactive;
    expect(container.read(isAppInBackgroundProvider), isTrue);

    // Paused -> background true
    container.read(appLifecycleStateProvider.notifier).state = AppLifecycleState.paused;
    expect(container.read(isAppInBackgroundProvider), isTrue);

    // Hidden -> background true
    container.read(appLifecycleStateProvider.notifier).state = AppLifecycleState.hidden;
    expect(container.read(isAppInBackgroundProvider), isTrue);

    // Resumed -> background false
    container.read(appLifecycleStateProvider.notifier).state = AppLifecycleState.resumed;
    expect(container.read(isAppInBackgroundProvider), isFalse);
  });
}
