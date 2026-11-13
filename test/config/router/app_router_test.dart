import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/router/router.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/layout.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/admin_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/login_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/register_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/caja/caja_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cliente_pedidos/cliente_pedidos_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cocina/cocina_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/home/home_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/mesas/mesas_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/not_found/no_page_found_screen.dart';
import 'package:itsqmet_mobile_pos/services/locator/router_locator.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

class _FakeGuard implements RouteGuard {
  _FakeGuard({this.target, this.async = false});

  String? target;
  final bool async;
  final List<RouteRequest> requests = [];

  @override
  FutureOr<String?> redirect(RouteRequest request) {
    requests.add(request);
    final result = request.path == AppRoutes.admin.path ? target : null;
    return async ? Future<String?>.value(result) : result;
  }
}

void main() {
  late GetIt services;

  setUp(() {
    services = GetIt.asNewInstance();
    registerRouterDependencies(services);
  });

  tearDown(() => services.reset());

  Future<GoRouter> pumpRouter(WidgetTester tester, String location) async {
    tester.setScreenSize(TestScreens.phone);
    final router = createAppRouter(
      locator: services,
      initialLocation: location,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();
    return router;
  }

  final expectedScreens = <AppRoute, Type>{
    AppRoutes.home: HomeScreen,
    AppRoutes.login: LoginScreen,
    AppRoutes.register: RegisterScreen,
    AppRoutes.clientePedidos: ClientePedidosScreen,
    AppRoutes.mesas: MesasScreen,
    AppRoutes.cocina: CocinaScreen,
    AppRoutes.caja: CajaScreen,
    AppRoutes.admin: AdminScreen,
    AppRoutes.notFound: NoPageFoundScreen,
  };

  test('every AppRoutes entry has an expected screen', () {
    expect(expectedScreens.keys.toSet(), AppRoutes.all.toSet());
  });

  for (final entry in expectedScreens.entries) {
    testWidgets('${entry.key.path} builds ${entry.value} inside AppShell', (
      tester,
    ) async {
      await pumpRouter(tester, entry.key.path);

      expect(find.byType(entry.value), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppShell),
          matching: find.byType(entry.value),
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets('routes can be reached by name', (tester) async {
    final router = await pumpRouter(tester, AppRoutes.home.path);

    router.goNamed(AppRoutes.caja.name);
    await tester.pumpAndSettle();

    expect(find.byType(CajaScreen), findsOneWidget);
  });

  testWidgets('an unknown path shows NoPageFoundScreen inside AppShell', (
    tester,
  ) async {
    await pumpRouter(tester, '/ruta/que/no/existe');

    expect(
      find.descendant(
        of: find.byType(AppShell),
        matching: find.byType(NoPageFoundScreen),
      ),
      findsOneWidget,
    );
    expect(find.text('404'), findsOneWidget);
  });

  testWidgets('Volver al Menú navigates from not-found to home', (
    tester,
  ) async {
    await pumpRouter(tester, '/ruta/que/no/existe');

    await tester.tap(find.text('Volver al Menú'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NoPageFoundScreen), findsNothing);
  });

  testWidgets('the guard redirect is applied with the matched route', (
    tester,
  ) async {
    final guard = _FakeGuard(target: AppRoutes.login.path);
    overrideRouteGuard(services, () => guard);

    await pumpRouter(tester, AppRoutes.admin.path);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AdminScreen), findsNothing);
    final adminRequest = guard.requests.firstWhere(
      (r) => r.path == AppRoutes.admin.path,
    );
    expect(adminRequest.route, AppRoutes.admin);
  });

  testWidgets('the guard receives a null route for unknown paths', (
    tester,
  ) async {
    final guard = _FakeGuard();
    overrideRouteGuard(services, () => guard);

    await pumpRouter(tester, '/desconocida');

    final request = guard.requests.firstWhere((r) => r.path == '/desconocida');
    expect(request.route, isNull);
  });

  testWidgets('an async guard redirect is applied', (tester) async {
    overrideRouteGuard(
      services,
      () => _FakeGuard(target: AppRoutes.register.path, async: true),
    );

    await pumpRouter(tester, AppRoutes.admin.path);

    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('a redirect to the current location is ignored', (tester) async {
    overrideRouteGuard(services, () => _FakeGuard(target: '/admin'));

    await pumpRouter(tester, AppRoutes.admin.path);

    expect(find.byType(AdminScreen), findsOneWidget);
  });

  testWidgets('RouterRefreshNotifier.notify re-evaluates the guard', (
    tester,
  ) async {
    final guard = _FakeGuard();
    overrideRouteGuard(services, () => guard);
    await pumpRouter(tester, AppRoutes.admin.path);
    expect(find.byType(AdminScreen), findsOneWidget);

    guard.target = AppRoutes.login.path;
    services<RouterRefreshNotifier>().notify();
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AdminScreen), findsNothing);
  });

  testWidgets('a guard overridden after the router was created is used', (
    tester,
  ) async {
    await pumpRouter(tester, AppRoutes.admin.path);
    expect(find.byType(AdminScreen), findsOneWidget);

    overrideRouteGuard(services, () => _FakeGuard(target: '/login'));
    services<RouterRefreshNotifier>().notify();
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
