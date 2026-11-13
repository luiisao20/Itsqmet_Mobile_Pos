import 'package:itsqmet_mobile_pos/config/router/app_route.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/rol.dart';

abstract final class AppRoutes {
  static const AppRoute home = AppRoute(name: 'home', path: '/');

  static const AppRoute login = AppRoute(
    name: 'login',
    path: '/login',
    access: RouteAccess.guestOnly,
  );

  static const AppRoute register = AppRoute(
    name: 'register',
    path: '/register',
    access: RouteAccess.guestOnly,
  );

  static const AppRoute clientePedidos = AppRoute(
    name: 'cliente-pedidos',
    path: '/cliente/pedidos',
    access: RouteAccess.authenticated,
    allowedRoles: {Rol.cliente},
  );

  static const AppRoute mesas = AppRoute(
    name: 'mesas',
    path: '/mesas',
    access: RouteAccess.authenticated,
    allowedRoles: {Rol.admin, Rol.mesero},
  );

  static const AppRoute cocina = AppRoute(
    name: 'cocina',
    path: '/cocina',
    access: RouteAccess.authenticated,
    allowedRoles: {Rol.admin, Rol.cocina, Rol.mesero},
  );

  static const AppRoute caja = AppRoute(
    name: 'caja',
    path: '/caja',
    access: RouteAccess.authenticated,
    allowedRoles: {Rol.admin, Rol.mesero},
  );

  static const AppRoute admin = AppRoute(
    name: 'admin',
    path: '/admin',
    access: RouteAccess.authenticated,
    allowedRoles: {Rol.admin},
  );

  static const AppRoute notFound = AppRoute(
    name: 'not-found',
    path: '/not-found',
  );

  static const List<AppRoute> all = [
    home,
    login,
    register,
    clientePedidos,
    mesas,
    cocina,
    caja,
    admin,
    notFound,
  ];

  static AppRoute? match(String path) {
    final normalized = path.length > 1 && path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    for (final route in all) {
      if (route.path == normalized) return route;
    }
    return null;
  }

  static AppRoute homeForRole(Rol? rol) => switch (rol) {
    Rol.cocina => cocina,
    Rol.cliente => clientePedidos,
    Rol.mesero => mesas,
    Rol.admin => admin,
    null => home,
  };
}
