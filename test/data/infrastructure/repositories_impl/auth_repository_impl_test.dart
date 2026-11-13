import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/repositories_impl/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mock_dio.dart';

class _MockAuthDatasource extends Mock implements AuthDatasource {}

const _userModel = AuthResponseModel(
  uuid: 'u-1',
  nombre: 'Ana',
  apellido: 'Pérez',
  email: 'ana@itsqmet.edu.ec',
  rol: Rol.mesero,
  activo: true,
  message: 'Login exitoso',
);

void main() {
  late _MockAuthDatasource datasource;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const LoginRequest(email: '', password: ''));
    registerFallbackValue(const ClienteLoginRequest(login: '', password: ''));
    registerFallbackValue(
      const ClienteRegistrationRequest(
        tipoIdentificacion: TipoIdentificacion.cedula,
        identificacion: '',
        razonSocial: '',
        email: '',
        password: '',
      ),
    );
  });

  setUp(() {
    datasource = _MockAuthDatasource();
    repository = AuthRepositoryImpl(datasource);
  });

  group('loginStaff', () {
    test('sends the credentials and maps the session', () async {
      when(() => datasource.loginStaff(any())).thenAnswer(
        (_) async => const AuthSessionModel(user: _userModel, token: 'jwt-1'),
      );

      final result = await repository.loginStaff(
        email: 'ana@itsqmet.edu.ec',
        password: 'pw',
      );

      expect(result, AuthResult(user: authUser(), token: 'jwt-1'));
      final request =
          verify(() => datasource.loginStaff(captureAny())).captured.single
              as LoginRequest;
      expect(request.toJson(), {
        'email': 'ana@itsqmet.edu.ec',
        'password': 'pw',
      });
    });

    test('surfaces InvalidCredentialsException from the datasource', () async {
      when(() => datasource.loginStaff(any()))
          .thenThrow(const InvalidCredentialsException());

      await expectLater(
        repository.loginStaff(email: 'a@b.c', password: 'x'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });

    test('maps a raw 500 "Credenciales inválidas" DioException', () async {
      when(() => datasource.loginStaff(any())).thenThrow(
        httpError(500, {
          'error': 'Error interno en el servidor',
          'mensaje': 'Credenciales inválidas',
        }),
      );

      await expectLater(
        repository.loginStaff(email: 'a@b.c', password: 'x'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });

  group('loginCliente', () {
    test('sends login/password and maps the session', () async {
      when(() => datasource.loginCliente(any())).thenAnswer(
        (_) async => const AuthSessionModel(
          user: AuthResponseModel(
            uuid: 'c-1',
            nombre: 'Juan',
            apellido: '',
            email: 'juan@x.com',
            rol: Rol.cliente,
            activo: true,
          ),
          token: 'client-jwt',
        ),
      );

      final result = await repository.loginCliente(
        login: '1712345678',
        password: 'pw',
      );

      expect(result.token, 'client-jwt');
      expect(result.user.rol, Rol.cliente);
      final request =
          verify(() => datasource.loginCliente(captureAny())).captured.single
              as ClienteLoginRequest;
      expect(request.toJson(), {'login': '1712345678', 'password': 'pw'});
    });

    test('maps network failures', () async {
      when(() => datasource.loginCliente(any())).thenThrow(connectionFailure());

      await expectLater(
        repository.loginCliente(login: 'x', password: 'y'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('registerCliente', () {
    test('maps the draft to the request and the session back', () async {
      when(() => datasource.registerCliente(any())).thenAnswer(
        (_) async => const AuthSessionModel(user: _userModel, token: 'new'),
      );

      final result = await repository.registerCliente(
        const ClienteRegistrationDraft(
          tipoIdentificacion: TipoIdentificacion.cedula,
          identificacion: '1712345678',
          razonSocial: 'Juan Cliente',
          telefono: '0999999999',
          email: 'juan@x.com',
          password: 'secreto',
        ),
      );

      expect(result.token, 'new');
      final request =
          verify(() => datasource.registerCliente(captureAny())).captured.single
              as ClienteRegistrationRequest;
      expect(request.toJson(), {
        'tipoIdentificacion': 'CEDULA',
        'identificacion': '1712345678',
        'razonSocial': 'Juan Cliente',
        'telefono': '0999999999',
        'email': 'juan@x.com',
        'password': 'secreto',
      });
    });

    test('surfaces validation errors', () async {
      when(() => datasource.registerCliente(any())).thenThrow(
        httpError(400, {
          'error': 'Validación fallida',
          'detalles': {'email': 'Correo inválido'},
        }),
      );

      await expectLater(
        repository.registerCliente(
          const ClienteRegistrationDraft(
            tipoIdentificacion: TipoIdentificacion.cedula,
            identificacion: '1',
            razonSocial: 'X',
            email: 'bad',
            password: 'secreto',
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('me', () {
    test('maps the current user', () async {
      when(() => datasource.me()).thenAnswer((_) async => _userModel);

      expect(await repository.me(), authUser());
    });

    test('surfaces 401 as UnauthorizedException', () async {
      when(() => datasource.me()).thenThrow(httpError(401));

      await expectLater(repository.me(), throwsA(isA<UnauthorizedException>()));
    });

    test('an unexpected payload error becomes UnknownException', () async {
      when(() => datasource.me())
          .thenThrow(const FormatException('bad payload'));

      await expectLater(repository.me(), throwsA(isA<UnknownException>()));
    });
  });

  group('logout', () {
    test('delegates to the datasource', () async {
      when(() => datasource.logout()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => datasource.logout()).called(1);
    });

    test('maps server errors', () async {
      when(() => datasource.logout()).thenThrow(httpError(503));

      await expectLater(repository.logout(), throwsA(isA<ServerException>()));
    });
  });
}
