import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/config/router/route_guard_auth.dart';
import 'package:itsqmet_mobile_pos/config/router/router.dart';
import 'package:itsqmet_mobile_pos/core/session/session_expired_notifier.dart';
import 'package:itsqmet_mobile_pos/core/storage/in_memory_session_storage.dart';
import 'package:itsqmet_mobile_pos/core/storage/session_storage.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth.dart';
import 'package:itsqmet_mobile_pos/services/locator/auth_locator.dart';
import 'package:itsqmet_mobile_pos/services/locator/router_locator.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../providers/cubits/auth/auth_fixtures.dart';

void main() {
  late GetIt services;
  late MockAuthRepository repository;
  late InMemorySessionStorage storage;

  setUp(() {
    services = GetIt.asNewInstance();
    repository = MockAuthRepository();
    storage = InMemorySessionStorage();
    services
      ..registerSingleton<AuthRepository>(repository)
      ..registerSingleton<SessionStorage>(storage)
      ..registerSingleton<SessionExpiredNotifier>(SessionExpiredNotifier());
    registerRouterDependencies(services);
    registerAuthDependencies(services);
  });

  tearDown(() => services.reset());

  test('registers a single AuthCubit and replaces the route guard', () {
    expect(services<AuthCubit>(), same(services<AuthCubit>()));
    expect(services<RouteGuard>(), isA<AuthRouteGuard>());
  });

  test('notifies the router on every session change', () async {
    final user = authUser(rol: Rol.admin);
    when(() => repository.loginStaff(email: 'a@x.com', password: 'secreto'))
        .thenAnswer((_) async => AuthResult(user: user, token: validJwt()));
    when(() => repository.logout()).thenAnswer((_) async {});
    var notifications = 0;
    services<RouterRefreshNotifier>().addListener(() => notifications++);
    final cubit = services<AuthCubit>();

    await cubit.ensureRestored();
    await pumpEventQueue();
    expect(notifications, 1);

    await cubit.loginStaff(email: 'a@x.com', password: 'secreto');
    await pumpEventQueue();
    expect(notifications, 2);

    await cubit.logout();
    await pumpEventQueue();
    expect(notifications, 3);
  });

  test('session expiry from the notifier closes the session', () async {
    await storage.saveToken(validJwt());
    await storage.saveUserJson(testCodec.encode(authUser()));
    final cubit = services<AuthCubit>();
    await cubit.ensureRestored();
    expect(cubit.state.isAuthenticated, isTrue);

    services<SessionExpiredNotifier>()
      ..notifyExpired()
      ..notifyExpired();
    await pumpEventQueue();

    expect(cubit.state, const AuthState.unauthenticated());
    expect(await storage.readToken(), isNull);
  });

  test('the stored user codec round-trips through AuthMapper JSON', () {
    final user = authUser(rol: Rol.cocina);

    final json = authSessionUserCodec.encode(user);

    expect(json, isNot(contains('token')));
    expect(authSessionUserCodec.decode(json), user);
  });

  test('reset closes the AuthCubit', () async {
    final cubit = services<AuthCubit>();

    await services.reset();

    expect(cubit.isClosed, isTrue);
  });
}
