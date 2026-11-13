import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/router/router.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/rol.dart';

void main() {
  group('AppRoutes paths and names', () {
    test('match the Angular app.routes.ts paths', () {
      expect(AppRoutes.home.path, '/');
      expect(AppRoutes.login.path, '/login');
      expect(AppRoutes.register.path, '/register');
      expect(AppRoutes.clientePedidos.path, '/cliente/pedidos');
      expect(AppRoutes.mesas.path, '/mesas');
      expect(AppRoutes.cocina.path, '/cocina');
      expect(AppRoutes.caja.path, '/caja');
      expect(AppRoutes.admin.path, '/admin');
      expect(AppRoutes.notFound.path, '/not-found');
    });

    test('all lists every route with unique names and paths', () {
      expect(AppRoutes.all, [
        AppRoutes.home,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.clientePedidos,
        AppRoutes.mesas,
        AppRoutes.cocina,
        AppRoutes.caja,
        AppRoutes.admin,
        AppRoutes.notFound,
      ]);
      expect(AppRoutes.all.map((r) => r.name).toSet(), hasLength(9));
      expect(AppRoutes.all.map((r) => r.path).toSet(), hasLength(9));
    });
  });

  group('AppRoutes access metadata', () {
    test('home and not-found are public', () {
      expect(AppRoutes.home.access, RouteAccess.public);
      expect(AppRoutes.notFound.access, RouteAccess.public);
      expect(AppRoutes.home.allowedRoles, isEmpty);
    });

    test('login and register are guest-only', () {
      expect(AppRoutes.login.access, RouteAccess.guestOnly);
      expect(AppRoutes.register.access, RouteAccess.guestOnly);
      expect(AppRoutes.login.isGuestOnly, isTrue);
      expect(AppRoutes.login.requiresAuth, isFalse);
    });

    test('role routes require auth with the Angular roleGuard roles', () {
      expect(AppRoutes.clientePedidos.allowedRoles, {Rol.cliente});
      expect(AppRoutes.mesas.allowedRoles, {Rol.admin, Rol.mesero});
      expect(AppRoutes.cocina.allowedRoles, {
        Rol.admin,
        Rol.cocina,
        Rol.mesero,
      });
      expect(AppRoutes.caja.allowedRoles, {Rol.admin, Rol.mesero});
      expect(AppRoutes.admin.allowedRoles, {Rol.admin});
      for (final route in [
        AppRoutes.clientePedidos,
        AppRoutes.mesas,
        AppRoutes.cocina,
        AppRoutes.caja,
        AppRoutes.admin,
      ]) {
        expect(route.access, RouteAccess.authenticated);
        expect(route.requiresAuth, isTrue);
      }
    });

    test('allowsRole accepts any role when no roles are required', () {
      expect(AppRoutes.home.allowsRole(Rol.cliente), isTrue);
      expect(AppRoutes.admin.allowsRole(Rol.admin), isTrue);
      expect(AppRoutes.admin.allowsRole(Rol.mesero), isFalse);
      expect(AppRoutes.cocina.allowsRole(Rol.cliente), isFalse);
    });

    test('homeForRole mirrors the Angular guestGuard redirects', () {
      expect(AppRoutes.homeForRole(Rol.cocina), AppRoutes.cocina);
      expect(AppRoutes.homeForRole(Rol.cliente), AppRoutes.clientePedidos);
      expect(AppRoutes.homeForRole(Rol.mesero), AppRoutes.mesas);
      expect(AppRoutes.homeForRole(Rol.admin), AppRoutes.admin);
      expect(AppRoutes.homeForRole(null), AppRoutes.home);
    });
  });

  group('AppRoutes.match', () {
    test('finds a route by exact path', () {
      expect(AppRoutes.match('/'), AppRoutes.home);
      expect(AppRoutes.match('/cliente/pedidos'), AppRoutes.clientePedidos);
    });

    test('ignores a trailing slash', () {
      expect(AppRoutes.match('/admin/'), AppRoutes.admin);
    });

    test('returns null for unknown paths', () {
      expect(AppRoutes.match('/desconocida'), isNull);
      expect(AppRoutes.match('/admin/extra'), isNull);
    });
  });
}
