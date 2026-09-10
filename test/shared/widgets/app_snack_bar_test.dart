import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/shared/widgets/app_snack_bar.dart';

void main() {
  group('AppSnackBar', () {
    testWidgets('showSuccess renders success icon, message and triggers action', (tester) async {
      var actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AppSnackBar.showSuccess(
                    context,
                    message: 'Rutina guardada exitosamente',
                    actionLabel: 'IR A RUTINAS',
                    onActionPressed: () => actionTriggered = true,
                  );
                },
                child: const Text('Mostrar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mostrar'));
      await tester.pumpAndSettle();

      // Message and action label
      expect(find.text('Rutina guardada exitosamente'), findsOneWidget);
      expect(find.text('IR A RUTINAS'), findsOneWidget);

      // Success icon is rendered
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Tap action
      await tester.tap(find.text('IR A RUTINAS'));
      await tester.pumpAndSettle();

      expect(actionTriggered, isTrue);
    });

    testWidgets('showError renders error icon and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AppSnackBar.showError(
                    context,
                    message: 'Ocurrió un error al guardar',
                  );
                },
                child: const Text('Mostrar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mostrar'));
      await tester.pumpAndSettle();

      expect(find.text('Ocurrió un error al guardar'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });
  });
}
