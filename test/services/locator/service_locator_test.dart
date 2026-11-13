import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/config/router/route_guard_auth.dart';
import 'package:itsqmet_mobile_pos/config/router/router.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/services/locator/admin_catalogo_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/admin_personas_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/auth_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/caja_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/cliente_pedidos_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/cocina_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/home_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/mesas_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/router_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';

class _DenyAllGuard implements RouteGuard {
  @override
  FutureOr<String?> redirect(RouteRequest request) => AppRoutes.login.path;
}

void main() {
  late GetIt services;

  setUp(() => services = GetIt.asNewInstance());

  tearDown(() => services.reset());

  test('setupLocator registers data, router defaults and features', () async {
    await setupLocator(services);

    expect(services.isRegistered<AuthRepository>(), isTrue);
    expect(services.isRegistered<PedidoRepository>(), isTrue);
    expect(services<RouteGuard>(), isA<AuthRouteGuard>());
    expect(services<RouterRefreshNotifier>(), isA<RouterRefreshNotifier>());
    expect(
      services<RouterRefreshNotifier>(),
      same(services<RouterRefreshNotifier>()),
    );
  });

  test('a later registration overrides the default guard', () async {
    await setupLocator(services);
    expect(services<RouteGuard>(), isA<AuthRouteGuard>());

    overrideRouteGuard(services, _DenyAllGuard.new);

    expect(services<RouteGuard>(), isA<_DenyAllGuard>());
    expect(services<RouteGuard>(), same(services<RouteGuard>()));
  });

  test('overrideRouteGuard also works when no guard is registered', () {
    overrideRouteGuard(services, _DenyAllGuard.new);

    expect(services<RouteGuard>(), isA<_DenyAllGuard>());
  });

  test('registerRouterDependencies keeps the refresh notifier', () {
    registerRouterDependencies(services);
    final notifier = services<RouterRefreshNotifier>();

    overrideRouteGuard(services, _DenyAllGuard.new);

    expect(services<RouterRefreshNotifier>(), same(notifier));
  });

  test('feature locator stubs can be called on a fresh GetIt', () {
    expect(() {
      registerAuthDependencies(services);
      registerHomeDependencies(services);
      registerClientePedidosDependencies(services);
      registerMesasDependencies(services);
      registerCocinaDependencies(services);
      registerCajaDependencies(services);
      registerAdminCatalogoDependencies(services);
      registerAdminPersonasDependencies(services);
    }, returnsNormally);
  });

  test('getIt is the shared GetIt instance', () {
    expect(identical(getIt, GetIt.instance), isTrue);
  });
}
