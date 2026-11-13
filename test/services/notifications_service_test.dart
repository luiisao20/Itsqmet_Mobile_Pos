import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';

void main() {
  Future<void> pumpHost(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      scaffoldMessengerKey: NotificationsService.messengerKey,
      home: const Scaffold(body: SizedBox.expand()),
    ),
  );

  SnackBar snackBar(WidgetTester tester) =>
      tester.widget<SnackBar>(find.byType(SnackBar));

  group('NotificationsService', () {
    testWidgets('showSuccess shows an emerald floating banner', (tester) async {
      await pumpHost(tester);

      NotificationsService.showSuccess('Guardado');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Guardado'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(snackBar(tester).backgroundColor, AppColors.emerald50);
      expect(snackBar(tester).behavior, SnackBarBehavior.floating);
    });

    testWidgets('showError shows a rose banner', (tester) async {
      await pumpHost(tester);

      NotificationsService.showError('Falló');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Falló'), findsOneWidget);
      expect(snackBar(tester).backgroundColor, AppColors.rose50);
    });

    testWidgets('showInfo shows a sky banner', (tester) async {
      await pumpHost(tester);

      NotificationsService.showInfo('Aviso');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aviso'), findsOneWidget);
      expect(snackBar(tester).backgroundColor, AppColors.sky50);
    });

    testWidgets('a new notification replaces the current one', (tester) async {
      await pumpHost(tester);

      NotificationsService.showSuccess('Primero');
      await tester.pump();
      NotificationsService.showError('Segundo');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Primero'), findsNothing);
      expect(find.text('Segundo'), findsOneWidget);
    });

    testWidgets('is a no-op when no messenger is attached', (tester) async {
      expect(() => NotificationsService.showError('x'), returnsNormally);
    });
  });
}
