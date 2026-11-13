import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/app.dart';
import 'package:itsqmet_mobile_pos/config/router/router.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/home/home_screen.dart';
import 'package:itsqmet_mobile_pos/services/locator/router_locator.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

void main() {
  late GetIt services;
  late GoRouter router;

  setUp(() {
    services = GetIt.asNewInstance();
    registerRouterDependencies(services);
    router = createAppRouter(locator: services);
  });

  tearDown(() {
    router.dispose();
    services.reset();
  });

  testWidgets('App renders the router home inside the shell with the theme', (
    tester,
  ) async {
    tester.setScreenSize(TestScreens.phone);

    await tester.pumpWidget(App(router: router));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.title, 'Restaurante POS');
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(app.theme, AppTheme.light);
    expect(app.scaffoldMessengerKey, NotificationsService.messengerKey);
    expect(app.routerConfig, same(router));
    expect(find.text('RESTAURANTEPOS'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('App without a router builds one from the GetIt instance', (
    tester,
  ) async {
    tester.setScreenSize(TestScreens.phone);
    registerRouterDependencies(GetIt.instance);
    addTearDown(GetIt.instance.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('App navigates through the router', (tester) async {
    tester.setScreenSize(TestScreens.phone);
    await tester.pumpWidget(App(router: router));

    router.go(AppRoutes.notFound.path);
    await tester.pumpAndSettle();

    expect(find.text('Página No Encontrada'), findsOneWidget);
  });

  testWidgets('notifications are shown through the app messenger key', (
    tester,
  ) async {
    tester.setScreenSize(TestScreens.phone);
    await tester.pumpWidget(App(router: router));

    NotificationsService.showInfo('Hola');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hola'), findsOneWidget);
  });
}
