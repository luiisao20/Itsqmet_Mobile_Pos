import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';
import 'package:itsqmet_mobile_pos/core/storage/in_memory_session_storage.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import 'auth_fixtures.dart';

class _CountingStorage extends InMemorySessionStorage {
  int clears = 0;

  @override
  Future<void> clear() async {
    clears++;
    await super.clear();
  }
}

class _FailingClearStorage extends InMemorySessionStorage {
  @override
  Future<void> clear() async => throw StateError('disco');
}

class _SlowUserStorage extends InMemorySessionStorage {
  final Completer<void> gate = Completer<void>();

  @override
  Future<String?> readUserJson() async {
    final json = await super.readUserJson();
    await gate.future;
    return json;
  }
}

void main() {
  final now = DateTime.utc(2026, 11, 13, 12);
  final validToken = jwtWithExp(now.add(const Duration(hours: 2)));
  final expiredToken = jwtWithExp(now.subtract(const Duration(minutes: 1)));
  final user = authUser();

  late MockAuthRepository repository;
  late _CountingStorage storage;
  late StreamController<void> expired;

  setUpAll(() {
    registerFallbackValue(
      const ClienteRegistrationDraft(
        tipoIdentificacion: TipoIdentificacion.cedula,
        identificacion: '1',
        razonSocial: 'x',
        email: 'x@x.com',
        password: '123456',
      ),
    );
  });

  setUp(() {
    repository = MockAuthRepository();
    storage = _CountingStorage();
    expired = StreamController<void>.broadcast();
  });

  tearDown(() => expired.close());

  AuthCubit build() => AuthCubit(
    repository: repository,
    storage: storage,
    userCodec: testCodec,
    sessionExpired: expired.stream,
    clock: () => now,
  );

  Future<void> seed(String? token, AuthUser? stored) async {
    if (token != null) await storage.saveToken(token);
    if (stored != null) await storage.saveUserJson(testCodec.encode(stored));
  }

  group('AuthState', () {
    test('starts unknown without user', () {
      final cubit = build();
      addTearDown(cubit.close);

      expect(cubit.state, const AuthState.unknown());
      expect(cubit.state.isUnknown, isTrue);
      expect(cubit.state.user, isNull);
      expect(cubit.state.rol, isNull);
    });

    test('authenticated exposes user and rol', () {
      final state = AuthState.authenticated(user);

      expect(state.isAuthenticated, isTrue);
      expect(state.user, user);
      expect(state.rol, Rol.mesero);
    });
  });

  group('ensureRestored', () {
    test('restores the stored session without calling the backend', () async {
      await seed(validToken, user);
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.ensureRestored();

      expect(cubit.state, AuthState.authenticated(user));
      expect(await storage.readToken(), validToken);
      verifyZeroInteractions(repository);
    });

    test('keeps a token without exp claim', () async {
      final token = jwtWithExp(null);
      await seed(token, user);
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.ensureRestored();

      expect(cubit.state, AuthState.authenticated(user));
    });

    test('is unauthenticated when nothing is stored', () async {
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.ensureRestored();

      expect(cubit.state, const AuthState.unauthenticated());
      expect(storage.clears, 0);
    });

    test('discards and clears an expired token', () async {
      await seed(expiredToken, user);
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.ensureRestored();

      expect(cubit.state, const AuthState.unauthenticated());
      expect(await storage.readToken(), isNull);
      expect(await storage.readUserJson(), isNull);
    });

    test('discards a token without stored user', () async {
      await seed(validToken, null);
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.ensureRestored();

      expect(cubit.state, const AuthState.unauthenticated());
      expect(await storage.readToken(), isNull);
    });

    test('discards an unreadable stored user', () async {
      await storage.saveToken(validToken);
      await storage.saveUserJson('no es json');
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.ensureRestored();

      expect(cubit.state, const AuthState.unauthenticated());
      expect(await storage.readUserJson(), isNull);
    });

    test('discards a stored user without uuid', () async {
      await seed(validToken, authUser(uuid: ''));
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.ensureRestored();

      expect(cubit.state, const AuthState.unauthenticated());
    });

    test('runs the restore only once', () async {
      await seed(validToken, user);
      final cubit = build();
      addTearDown(cubit.close);

      final first = cubit.ensureRestored();
      final second = cubit.ensureRestored();

      expect(identical(first, second), isTrue);
      await first;
      expect(cubit.state, AuthState.authenticated(user));
    });
  });

  group('login and register', () {
    final result = AuthResult(user: user, token: validToken);

    test('loginStaff persists token and user and authenticates', () async {
      when(() => repository.loginStaff(email: 'ana@x.com', password: 'secreto'))
          .thenAnswer((_) async => result);
      final cubit = build();
      addTearDown(cubit.close);

      final logged = await cubit.loginStaff(
        email: 'ana@x.com',
        password: 'secreto',
      );

      expect(logged, user);
      expect(cubit.state, AuthState.authenticated(user));
      expect(await storage.readToken(), validToken);
      expect(testCodec.decode((await storage.readUserJson())!), user);
    });

    test('loginCliente persists the session', () async {
      final cliente = authUser(rol: Rol.cliente);
      when(
        () => repository.loginCliente(login: '1718293041', password: 'abc123'),
      ).thenAnswer((_) async => AuthResult(user: cliente, token: validToken));
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.loginCliente(login: '1718293041', password: 'abc123');

      expect(cubit.state, AuthState.authenticated(cliente));
      expect(await storage.readToken(), validToken);
    });

    test('registerCliente persists the session', () async {
      const draft = ClienteRegistrationDraft(
        tipoIdentificacion: TipoIdentificacion.cedula,
        identificacion: '1718293041',
        razonSocial: 'Juan Pérez',
        email: 'juan@x.com',
        password: 'abc123',
      );
      final cliente = authUser(rol: Rol.cliente);
      when(
        () => repository.registerCliente(draft),
      ).thenAnswer((_) async => AuthResult(user: cliente, token: validToken));
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.registerCliente(draft);

      expect(cubit.state, AuthState.authenticated(cliente));
      expect(await storage.readToken(), validToken);
    });

    test('a failed login rethrows and keeps the session empty', () async {
      when(
        () => repository.loginStaff(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const InvalidCredentialsException());
      final cubit = build();
      addTearDown(cubit.close);

      await expectLater(
        cubit.loginStaff(email: 'a@x.com', password: 'mal'),
        throwsA(isA<InvalidCredentialsException>()),
      );

      expect(cubit.state, const AuthState.unauthenticated());
      expect(await storage.readToken(), isNull);
    });
  });

  group('logout', () {
    test('clears the session without waiting for the backend', () async {
      await seed(validToken, user);
      when(() => repository.logout())
          .thenAnswer((_) => Completer<void>().future);
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.ensureRestored();

      await cubit.logout();

      verify(() => repository.logout()).called(1);
      expect(cubit.state, const AuthState.unauthenticated());
      expect(await storage.readToken(), isNull);
    });

    test('unauthenticates even when the storage cannot be cleared', () async {
      final failing = _FailingClearStorage();
      await failing.saveToken(validToken);
      await failing.saveUserJson(testCodec.encode(user));
      when(() => repository.logout()).thenAnswer((_) async {});
      final cubit = AuthCubit(
        repository: repository,
        storage: failing,
        userCodec: testCodec,
        clock: () => now,
      );
      addTearDown(cubit.close);
      await cubit.ensureRestored();

      await cubit.logout();

      expect(cubit.state, const AuthState.unauthenticated());
    });

    test('calls the backend, clears storage and unauthenticates', () async {
      await seed(validToken, user);
      when(() => repository.logout()).thenAnswer((_) async {});
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.ensureRestored();

      await cubit.logout();

      verify(() => repository.logout()).called(1);
      expect(cubit.state, const AuthState.unauthenticated());
      expect(await storage.readToken(), isNull);
      expect(await storage.readUserJson(), isNull);
    });

    test('still clears the session when the backend fails', () async {
      await seed(validToken, user);
      when(() => repository.logout()).thenThrow(const NetworkException());
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.ensureRestored();

      await cubit.logout();

      expect(cubit.state, const AuthState.unauthenticated());
      expect(await storage.readToken(), isNull);
    });
  });

  group('session expired', () {
    test('an expiry during the restore keeps the session closed', () async {
      final slow = _SlowUserStorage();
      await slow.saveToken(validToken);
      await slow.saveUserJson(testCodec.encode(user));
      final cubit = AuthCubit(
        repository: repository,
        storage: slow,
        userCodec: testCodec,
        sessionExpired: expired.stream,
        clock: () => now,
      );
      addTearDown(cubit.close);

      final restoring = cubit.ensureRestored();
      await pumpEventQueue();
      expired.add(null);
      await slow.clear();
      await pumpEventQueue();
      slow.gate.complete();
      await restoring;

      expect(cubit.state, const AuthState.unauthenticated());
    });

    test('logs out once and ignores repeated events', () async {
      await seed(validToken, user);
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.ensureRestored();
      final states = <AuthState>[];
      final sub = cubit.stream.listen(states.add);
      addTearDown(sub.cancel);

      expired
        ..add(null)
        ..add(null)
        ..add(null);
      await pumpEventQueue();

      expect(states, [const AuthState.unauthenticated()]);
      expect(storage.clears, 1);
      expect(await storage.readToken(), isNull);
      verifyNever(() => repository.logout());
    });

    test('is ignored when there is no session', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.ensureRestored();

      expired.add(null);
      await pumpEventQueue();

      expect(cubit.state, const AuthState.unauthenticated());
      expect(storage.clears, 0);
    });

    test('stops listening after close', () async {
      final cubit = build();
      await cubit.close();

      expect(expired.hasListener, isFalse);
    });
  });

  group('isTokenExpired', () {
    test('reads the exp claim', () {
      expect(isTokenExpired(validToken, now), isFalse);
      expect(isTokenExpired(expiredToken, now), isTrue);
      expect(isTokenExpired(jwtWithExp(now), now), isTrue);
    });

    test('tokens without a readable exp are not considered expired', () {
      expect(isTokenExpired(jwtWithExp(null), now), isFalse);
      expect(isTokenExpired('opaco', now), isFalse);
      expect(isTokenExpired('a.%%%.c', now), isFalse);
    });
  });
}
