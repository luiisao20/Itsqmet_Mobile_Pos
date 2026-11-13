import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/router/route_guard_auth.dart';
import 'package:itsqmet_mobile_pos/config/router/router.dart';
import 'package:itsqmet_mobile_pos/core/storage/in_memory_session_storage.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth.dart';

import '../../helpers/fixtures.dart';
import '../../providers/cubits/auth/auth_fixtures.dart';

RouteRequest request(String location) {
  final uri = Uri.parse(location);
  return RouteRequest(uri: uri, route: AppRoutes.match(uri.path));
}

void main() {
  late InMemorySessionStorage storage;
  late AuthCubit cubit;

  setUp(() {
    storage = InMemorySessionStorage();
    cubit = AuthCubit(
      repository: MockAuthRepository(),
      storage: storage,
      userCodec: testCodec,
    );
  });

  tearDown(() => cubit.close());

  Future<void> seed(Rol rol) async {
    await storage.saveToken(validJwt());
    await storage.saveUserJson(testCodec.encode(authUser(rol: rol)));
  }

  Future<AuthRouteGuard> guardWith(Rol? rol) async {
    if (rol != null) await seed(rol);
    await cubit.ensureRestored();
    return AuthRouteGuard(cubit);
  }

  test(
    'restores the session before deciding while the state is unknown',
    () async {
      await seed(Rol.admin);
      final guard = AuthRouteGuard(cubit);

      final result = guard.redirect(request('/admin'));

      expect(result, isA<Future<String?>>());
      expect(await result, isNull);
      expect(cubit.state.isAuthenticated, isTrue);
    },
  );

  test('decides synchronously once the session is known', () async {
    final guard = await guardWith(null);

    expect(guard.redirect(request('/admin')), '/login');
  });

  group('without session', () {
    test('public routes and unknown paths are allowed', () async {
      final guard = await guardWith(null);

      expect(guard.redirect(request('/')), isNull);
      expect(guard.redirect(request('/not-found')), isNull);
      expect(guard.redirect(request('/no-existe')), isNull);
    });

    test('guest routes are allowed', () async {
      final guard = await guardWith(null);

      expect(guard.redirect(request('/login')), isNull);
      expect(guard.redirect(request('/register')), isNull);
    });

    test('protected routes redirect to /login', () async {
      final guard = await guardWith(null);

      for (final path in [
        '/cliente/pedidos',
        '/mesas',
        '/cocina',
        '/caja',
        '/admin',
      ]) {
        expect(guard.redirect(request(path)), '/login', reason: path);
      }
    });
  });

  group('guest routes with session redirect to the role home', () {
    final expected = {
      Rol.cocina: '/cocina',
      Rol.cliente: '/cliente/pedidos',
      Rol.mesero: '/mesas',
      Rol.admin: '/admin',
    };
    for (final entry in expected.entries) {
      test(entry.key.name, () async {
        final guard = await guardWith(entry.key);

        expect(guard.redirect(request('/login')), entry.value);
        expect(guard.redirect(request('/register')), entry.value);
      });
    }
  });

  group('returnUrl', () {
    test('is followed when the role may open it', () async {
      final guard = await guardWith(Rol.mesero);

      expect(
        guard.redirect(request('/login?returnUrl=%2Fcaja%3Fmesa%3D3')),
        '/caja?mesa=3',
      );
      expect(guard.redirect(request('/login?returnUrl=%2F')), '/');
    });

    test('is ignored when it is not allowed or not internal', () async {
      final guard = await guardWith(Rol.mesero);

      for (final returnUrl in [
        '/admin',
        '/login',
        '/no-existe',
        '//evil.com/caja',
        'https://evil.com/caja',
        'caja',
      ]) {
        expect(
          guard.redirect(
            request('/login?returnUrl=${Uri.encodeComponent(returnUrl)}'),
          ),
          '/mesas',
          reason: returnUrl,
        );
      }
    });
  });

  group('role metadata', () {
    final matrix = <Rol, Map<String, String?>>{
      Rol.admin: {
        '/mesas': null,
        '/cocina': null,
        '/caja': null,
        '/admin': null,
        '/cliente/pedidos': '/',
      },
      Rol.mesero: {
        '/mesas': null,
        '/cocina': null,
        '/caja': null,
        '/admin': '/',
        '/cliente/pedidos': '/',
      },
      Rol.cocina: {
        '/mesas': '/',
        '/cocina': null,
        '/caja': '/',
        '/admin': '/',
        '/cliente/pedidos': '/',
      },
      Rol.cliente: {
        '/mesas': '/',
        '/cocina': '/',
        '/caja': '/',
        '/admin': '/',
        '/cliente/pedidos': null,
      },
    };
    for (final entry in matrix.entries) {
      test(entry.key.name, () async {
        final guard = await guardWith(entry.key);

        for (final route in entry.value.entries) {
          expect(
            guard.redirect(request(route.key)),
            route.value,
            reason: '${entry.key.name} ${route.key}',
          );
        }
        expect(guard.redirect(request('/')), isNull);
      });
    }
  });
}
