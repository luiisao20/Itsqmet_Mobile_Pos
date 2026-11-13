import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/router/app_route.dart';
import 'package:itsqmet_mobile_pos/config/router/app_routes.dart';
import 'package:itsqmet_mobile_pos/config/router/route_guard.dart';
import 'package:itsqmet_mobile_pos/config/router/router_refresh_notifier.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/app_shell.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/admin_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/login_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/register_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/caja/caja_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cliente_pedidos/cliente_pedidos_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/cocina/cocina_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/home/home_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/mesas/mesas_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/not_found/no_page_found_screen.dart';
import 'package:material_ui/material_ui.dart';

typedef ScreenBuilder = Widget Function(AppRoute route);

Widget screenFor(AppRoute route) => switch (route) {
  AppRoutes.home => const HomeScreen(),
  AppRoutes.login => const LoginScreen(),
  AppRoutes.register => const RegisterScreen(),
  AppRoutes.clientePedidos => const ClientePedidosScreen(),
  AppRoutes.mesas => const MesasScreen(),
  AppRoutes.cocina => const CocinaScreen(),
  AppRoutes.caja => const CajaScreen(),
  AppRoutes.admin => const AdminScreen(),
  _ => const NoPageFoundScreen(),
};

GoRouter createAppRouter({
  GetIt? locator,
  String? initialLocation,
  ScreenBuilder screenBuilder = screenFor,
}) {
  final services = locator ?? GetIt.instance;

  return GoRouter(
    initialLocation: initialLocation ?? AppRoutes.home.path,
    refreshListenable: services<RouterRefreshNotifier>(),
    redirect: (context, state) => _redirect(services, state),
    errorBuilder: (context, state) =>
        const AppShell(child: NoPageFoundScreen()),
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          for (final route in AppRoutes.all) _route(route, screenBuilder),
        ],
      ),
    ],
  );
}

GoRoute _route(AppRoute route, ScreenBuilder screenBuilder) => GoRoute(
  path: route.path,
  name: route.name,
  builder: (context, state) => screenBuilder(route),
);

FutureOr<String?> _redirect(GetIt services, GoRouterState state) {
  final request = RouteRequest(
    uri: state.uri,
    route: AppRoutes.match(state.uri.path),
  );
  final result = services<RouteGuard>().redirect(request);
  if (result is Future<String?>) {
    return result.then((target) => _effectiveTarget(target, request));
  }
  return _effectiveTarget(result, request);
}

String? _effectiveTarget(String? target, RouteRequest request) {
  if (target == null) return null;
  if (target == request.location || target == request.path) return null;
  return target;
}
