import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/datasources/api_auth_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_dio.dart';

const _staffBody = {
  'uuid': 'u-1',
  'nombre': 'Ana',
  'apellido': 'Pérez',
  'email': 'ana@itsqmet.edu.ec',
  'rol': 'MESERO',
  'activo': true,
  'message': 'Login exitoso',
};

void main() {
  late MockDio dio;
  late ApiAuthDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = ApiAuthDatasource(dio);
  });

  group('loginStaff', () {
    test('POSTs /auth/login and takes the token from the jwt cookie', () async {
      when(
        () => dio.post<dynamic>(
          '/auth/login',
          data: {'email': 'ana@itsqmet.edu.ec', 'password': 'pw'},
        ),
      ).thenAnswer(
        (_) async => okResponse(
          _staffBody,
          headers: {
            'set-cookie': ['jwt=abc.def.ghi; Path=/; HttpOnly; Max-Age=86400'],
          },
        ),
      );

      final session = await datasource.loginStaff(
        const LoginRequest(email: 'ana@itsqmet.edu.ec', password: 'pw'),
      );

      expect(session.token, 'abc.def.ghi');
      expect(session.user.uuid, 'u-1');
      expect(session.user.rol, Rol.mesero);
      expect(session.user.message, 'Login exitoso');
    });

    test('falls back to a token field in the body', () async {
      when(() => dio.post<dynamic>('/auth/login', data: any(named: 'data')))
          .thenAnswer(
            (_) async => okResponse({..._staffBody, 'token': 'body-token'}),
          );

      final session = await datasource.loginStaff(
        const LoginRequest(email: 'a@b.c', password: 'pw'),
      );

      expect(session.token, 'body-token');
    });

    test('prefers the cookie over the body token', () async {
      when(() => dio.post<dynamic>('/auth/login', data: any(named: 'data')))
          .thenAnswer(
            (_) async => okResponse(
              {..._staffBody, 'token': 'body-token'},
              headers: {
                'set-cookie': ['jwt=cookie-token; Path=/'],
              },
            ),
          );

      final session = await datasource.loginStaff(
        const LoginRequest(email: 'a@b.c', password: 'pw'),
      );

      expect(session.token, 'cookie-token');
    });

    test('throws UnknownException when no token is received', () async {
      when(() => dio.post<dynamic>('/auth/login', data: any(named: 'data')))
          .thenAnswer((_) async => okResponse(_staffBody));

      await expectLater(
        datasource.loginStaff(
          const LoginRequest(email: 'a@b.c', password: 'p'),
        ),
        throwsA(
          isA<UnknownException>().having(
            (e) => e.message,
            'message',
            'No se recibió el token de sesión',
          ),
        ),
      );
    });

    test(
      'maps the 500 "Credenciales inválidas" to InvalidCredentials',
      () async {
        when(() => dio.post<dynamic>('/auth/login', data: any(named: 'data')))
            .thenThrow(
              httpError(500, {
                'error': 'Error interno en el servidor',
                'mensaje': 'Credenciales inválidas',
              }),
            );

        await expectLater(
          datasource.loginStaff(
            const LoginRequest(email: 'a@b.c', password: 'x'),
          ),
          throwsA(isA<InvalidCredentialsException>()),
        );
      },
    );

    test('a non-object body is an UnknownException', () async {
      when(() => dio.post<dynamic>('/auth/login', data: any(named: 'data')))
          .thenAnswer(
            (_) async => okResponse(
              'oops',
              headers: {
                'set-cookie': ['jwt=abc'],
              },
            ),
          );

      await expectLater(
        datasource.loginStaff(
          const LoginRequest(email: 'a@b.c', password: 'x'),
        ),
        throwsA(isA<UnknownException>()),
      );
    });
  });

  group('loginCliente', () {
    test('POSTs /auth/cliente/login', () async {
      when(
        () => dio.post<dynamic>(
          '/auth/cliente/login',
          data: {'login': '1712345678', 'password': 'pw'},
        ),
      ).thenAnswer(
        (_) async => okResponse(
          {..._staffBody, 'rol': 'CLIENTE', 'apellido': null},
          headers: {
            'Set-Cookie': ['jwt=client-token; Path=/'],
          },
        ),
      );

      final session = await datasource.loginCliente(
        const ClienteLoginRequest(login: '1712345678', password: 'pw'),
      );

      expect(session.token, 'client-token');
      expect(session.user.rol, Rol.cliente);
      expect(session.user.apellido, '');
    });
  });

  group('registerCliente', () {
    test(
      'POSTs /auth/cliente/registro (201) and returns the session',
      () async {
        const draft = ClienteRegistrationDraft(
          tipoIdentificacion: TipoIdentificacion.cedula,
          identificacion: '1712345678',
          razonSocial: 'Juan Cliente',
          email: 'juan@x.com',
          password: 'secreto',
        );
        when(
          () => dio.post<dynamic>(
            '/auth/cliente/registro',
            data: ClienteRegistrationRequest.fromDraft(draft).toJson(),
          ),
        ).thenAnswer(
          (_) async => okResponse(
            {..._staffBody, 'rol': 'CLIENTE'},
            status: 201,
            headers: {
              'set-cookie': ['jwt=new-client; Path=/'],
            },
          ),
        );

        final session = await datasource.registerCliente(
          ClienteRegistrationRequest.fromDraft(draft),
        );

        expect(session.token, 'new-client');
        verify(
          () => dio.post<dynamic>(
            '/auth/cliente/registro',
            data: {
              'tipoIdentificacion': 'CEDULA',
              'identificacion': '1712345678',
              'razonSocial': 'Juan Cliente',
              'email': 'juan@x.com',
              'password': 'secreto',
            },
          ),
        ).called(1);
      },
    );

    test('maps a validation error (400 detalles)', () async {
      when(
        () => dio.post<dynamic>(
          '/auth/cliente/registro',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        httpError(400, {
          'error': 'Validación fallida',
          'detalles': {'email': 'Correo inválido'},
        }),
      );

      await expectLater(
        datasource.registerCliente(
          const ClienteRegistrationRequest(
            tipoIdentificacion: TipoIdentificacion.cedula,
            identificacion: '1',
            razonSocial: 'X',
            email: 'bad',
            password: 'secreto',
          ),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.fieldErrors,
            'fieldErrors',
            {'email': 'Correo inválido'},
          ),
        ),
      );
    });
  });

  group('me', () {
    test('GETs /auth/me', () async {
      when(() => dio.get<dynamic>('/auth/me'))
          .thenAnswer((_) async => okResponse(_staffBody));

      final user = await datasource.me();

      expect(user.email, 'ana@itsqmet.edu.ec');
      expect(user.rol, Rol.mesero);
    });

    test('maps a 401 to UnauthorizedException', () async {
      when(() => dio.get<dynamic>('/auth/me')).thenThrow(
        httpError(401, {
          'error': 'No autorizado',
          'message': 'Sesión inválida o expirada',
        }),
      );

      await expectLater(datasource.me(), throwsA(isA<UnauthorizedException>()));
    });
  });

  group('logout', () {
    test('POSTs /auth/logout', () async {
      when(() => dio.post<dynamic>('/auth/logout'))
          .thenAnswer((_) async => okResponse(null));

      await datasource.logout();

      verify(() => dio.post<dynamic>('/auth/logout')).called(1);
    });

    test('maps network failures', () async {
      when(() => dio.post<dynamic>('/auth/logout'))
          .thenThrow(connectionFailure());

      await expectLater(datasource.logout(), throwsA(isA<NetworkException>()));
    });
  });
}
