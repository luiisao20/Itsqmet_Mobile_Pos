import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/app_navbar.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/notificaciones/notificaciones.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';
import '../screens/auth/auth_test_app.dart';

class _MockOrderAlerts extends MockCubit<OrderAlertsState>
    implements OrderAlertsCubit {}

Finder _inNavbar(Finder finder) =>
    find.descendant(of: find.byType(AppNavbar), matching: finder);

Finder _countIn(Key badgeKey, String count) =>
    find.descendant(of: find.byKey(badgeKey), matching: find.text(count));

void main() {
  late AuthTestServices services;
  late _MockOrderAlerts alerts;

  void unseen(int count) => whenListen(
    alerts,
    const Stream<OrderAlertsState>.empty(),
    initialState: OrderAlertsState(unseen: count, listening: true),
  );

  setUp(() async {
    services = await AuthTestServices.register();
    alerts = _MockOrderAlerts();
    unseen(3);
    GetIt.instance.registerSingleton<OrderAlertsCubit>(alerts);
  });

  tearDown(() => GetIt.instance.reset());

  testWidgets('tablet: the kitchen link shows the unseen orders', (
    tester,
  ) async {
    await services.signIn(authUser(rol: Rol.cocina));

    await tester.pumpAuthRouter('/', size: TestScreens.tabletLandscape);

    expect(_inNavbar(_countIn(AppNavbar.kitchenBadgeKey, '3')), findsOne);
  });

  testWidgets('phone: the menu button and the kitchen entry show the count', (
    tester,
  ) async {
    await services.signIn(authUser(rol: Rol.mesero));
    await tester.pumpAuthRouter('/');

    expect(_inNavbar(_countIn(AppNavbar.menuBadgeKey, '3')), findsOneWidget);

    await tester.tap(_inNavbar(find.byIcon(Icons.menu)));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(AppNavbar.mobileMenuKey),
        matching: _countIn(AppNavbar.kitchenBadgeKey, '3'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('no badge while there are no unseen orders', (tester) async {
    unseen(0);
    await services.signIn(authUser(rol: Rol.cocina));

    await tester.pumpAuthRouter('/', size: TestScreens.tabletLandscape);

    expect(find.byKey(AppNavbar.kitchenBadgeKey), findsNothing);
    expect(_inNavbar(find.text('Monitor Cocina')), findsOneWidget);
  });

  testWidgets('opening the kitchen screen clears the counter', (tester) async {
    await services.signIn(authUser(rol: Rol.cocina));

    final router = await tester.pumpAuthRouter(
      '/cocina',
      size: TestScreens.tabletLandscape,
    );

    verify(() => alerts.kitchenOpened()).called(1);
    verifyNever(() => alerts.kitchenClosed());

    router.go('/');
    await tester.pumpAndSettle();

    verify(() => alerts.kitchenClosed()).called(1);
  });

  testWidgets('other screens do not touch the counter', (tester) async {
    await services.signIn(authUser(rol: Rol.mesero));

    await tester.pumpAuthRouter('/mesas', size: TestScreens.tabletLandscape);

    verifyNever(() => alerts.kitchenOpened());
  });
}
