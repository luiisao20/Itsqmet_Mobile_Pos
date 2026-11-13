import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';
import 'package:itsqmet_mobile_pos/core/storage/in_memory_session_storage.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import 'auth_fixtures.dart';

void main() {
  late MockAuthRepository repository;
  late AuthCubit auth;

  setUp(() {
    repository = MockAuthRepository();
    auth = AuthCubit(
      repository: repository,
      storage: InMemorySessionStorage(),
      userCodec: testCodec,
    );
  });

  tearDown(() => auth.close());

  LoginCubit build() => LoginCubit(session: () => auth);

  test('starts on the cliente tab without error', () {
    final cubit = build();
    addTearDown(cubit.close);

    expect(cubit.state, const LoginState());
    expect(cubit.state.tab, LoginTab.cliente);
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.errorMessage, isNull);
  });

  test('changing tab clears the error', () async {
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.submitStaff(email: ' ', password: '');
    expect(cubit.state.errorMessage, isNotNull);

    cubit.setTab(LoginTab.staff);

    expect(cubit.state.tab, LoginTab.staff);
    expect(cubit.state.errorMessage, isNull);
  });

  group('validation', () {
    test('staff requires email and password', () async {
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.submitStaff(email: '   ', password: 'x');
      expect(cubit.state.errorMessage, 'Por favor completa todos los campos');

      await cubit.submitStaff(email: 'a@x.com', password: '');
      expect(cubit.state.errorMessage, 'Por favor completa todos los campos');
      verifyZeroInteractions(repository);
    });

    test('cliente requires login and password', () async {
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.submitCliente(login: '', password: 'x');

      expect(cubit.state.errorMessage, 'Por favor completa todos los campos');
      expect(cubit.state.loading, isFalse);
      verifyZeroInteractions(repository);
    });
  });

  test('staff login trims the email and authenticates', () async {
    final user = authUser(rol: Rol.admin);
    when(() => repository.loginStaff(email: 'admin@x.com', password: ' clave '))
        .thenAnswer((_) async => AuthResult(user: user, token: validJwt()));
    final cubit = build();
    addTearDown(cubit.close);
    final states = <LoginState>[];
    final sub = cubit.stream.listen(states.add);
    addTearDown(sub.cancel);

    await cubit.submitStaff(email: '  admin@x.com ', password: ' clave ');
    await pumpEventQueue();

    expect(states.first.loading, isTrue);
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.errorMessage, isNull);
    expect(auth.state, AuthState.authenticated(user));
  });

  test('cliente login trims the login and authenticates', () async {
    final user = authUser(rol: Rol.cliente);
    when(() => repository.loginCliente(login: '1718293041', password: 'abc'))
        .thenAnswer((_) async => AuthResult(user: user, token: validJwt()));
    final cubit = build();
    addTearDown(cubit.close);

    await cubit.submitCliente(login: ' 1718293041 ', password: 'abc');

    expect(auth.state, AuthState.authenticated(user));
  });

  group('errors use the web fallback messages', () {
    test('staff', () async {
      when(
        () => repository.loginStaff(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const InvalidCredentialsException());
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.submitStaff(email: 'a@x.com', password: 'mal');

      expect(
        cubit.state.errorMessage,
        'Credenciales inválidas de personal. Verifica tus datos.',
      );
      expect(cubit.state.loading, isFalse);
    });

    test('cliente', () async {
      when(
        () => repository.loginCliente(
          login: any(named: 'login'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ServerException('detalle interno del servidor'));
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.submitCliente(login: 'ana', password: 'mal');

      expect(
        cubit.state.errorMessage,
        'Credenciales inválidas. Verifica tu correo o cédula y contraseña.',
      );
    });

    test('connection problems show the connection message', () async {
      when(
        () => repository.loginCliente(
          login: any(named: 'login'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NetworkException());
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.submitCliente(login: 'ana', password: 'x');

      expect(cubit.state.errorMessage, 'No se pudo conectar con el servidor');
    });

    test('unexpected errors fall back too', () async {
      when(
        () => repository.loginStaff(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(StateError('x'));
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.submitStaff(email: 'a@x.com', password: 'x');

      expect(
        cubit.state.errorMessage,
        'Credenciales inválidas de personal. Verifica tus datos.',
      );
    });
  });

  test('ignores a second submit while loading', () async {
    when(
      () => repository.loginStaff(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AuthResult(user: authUser(), token: validJwt()));
    final cubit = build();
    addTearDown(cubit.close);

    final first = cubit.submitStaff(email: 'a@x.com', password: 'x');
    final second = cubit.submitStaff(email: 'a@x.com', password: 'x');
    await Future.wait([first, second]);

    verify(() => repository.loginStaff(email: 'a@x.com', password: 'x'))
        .called(1);
  });
}
