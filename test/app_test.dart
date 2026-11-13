import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/app.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('App renders the shell preview with the app theme', (
    tester,
  ) async {
    tester.setScreenSize(TestScreens.phone);

    await tester.pumpWidget(const App());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.title, 'Restaurante POS');
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(app.theme, AppTheme.light);
    expect(app.scaffoldMessengerKey, NotificationsService.messengerKey);
    expect(find.text('RESTAURANTEPOS'), findsOneWidget);
    expect(find.text('Base de la aplicación lista'), findsOneWidget);
  });

  testWidgets('notifications are shown through the app messenger key', (
    tester,
  ) async {
    tester.setScreenSize(TestScreens.phone);
    await tester.pumpWidget(const App());

    NotificationsService.showInfo('Hola');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hola'), findsOneWidget);
  });
}
