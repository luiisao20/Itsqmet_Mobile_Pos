import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';
import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';

DioException _badResponse(int status, Object? data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: data,
    ),
  );
}

DioException _ofType(DioExceptionType type, {Object? error}) {
  return DioException(
    requestOptions: RequestOptions(path: '/x'),
    type: type,
    error: error,
  );
}

void main() {
  group('ErrorMapper.fromDio - HTTP responses', () {
    test(
      '400 with detalles becomes a ValidationException with field errors',
      () {
        final result = ErrorMapper.fromDio(
          _badResponse(400, {
            'error': 'Validación fallida',
            'detalles': {
              'nombre': 'El nombre es obligatorio',
              'precioUnitario': 'Debe ser mayor a 0',
            },
          }),
        );

        expect(result, isA<ValidationException>());
        final validation = result as ValidationException;
        expect(validation.message, 'Validación fallida');
        expect(validation.fieldErrors, {
          'nombre': 'El nombre es obligatorio',
          'precioUnitario': 'Debe ser mayor a 0',
        });
      },
    );

    test('400 detalles with non-string values are stringified', () {
      final result = ErrorMapper.fromDio(
        _badResponse(400, {
          'error': 'Validación fallida',
          'detalles': {
            'cantidad': 5,
            'lista': ['a', 'b'],
            'nulo': null,
          },
        }),
      );

      final validation = result as ValidationException;
      expect(validation.fieldErrors['cantidad'], '5');
      expect(validation.fieldErrors['lista'], isNotEmpty);
      expect(validation.fieldErrors.containsKey('nulo'), isFalse);
    });

    test('400 with only an error message becomes a BadRequestException', () {
      final result = ErrorMapper.fromDio(
        _badResponse(400, {'error': 'La mesa ya está ocupada'}),
      );

      expect(result, isA<BadRequestException>());
      expect(result.message, 'La mesa ya está ocupada');
    });

    test('409 becomes a BadRequestException', () {
      final result = ErrorMapper.fromDio(
        _badResponse(409, {'error': 'Ya existe un registro'}),
      );

      expect(result, isA<BadRequestException>());
      expect(result.message, 'Ya existe un registro');
    });

    test('401 becomes an UnauthorizedException using message first', () {
      final result = ErrorMapper.fromDio(
        _badResponse(401, {
          'error': 'No autorizado',
          'message': 'Sesión inválida o expirada',
        }),
      );

      expect(result, isA<UnauthorizedException>());
      expect(result.message, 'Sesión inválida o expirada');
    });

    test('403 becomes a ForbiddenException', () {
      final result = ErrorMapper.fromDio(
        _badResponse(403, {
          'error': 'Acceso denegado',
          'message': 'No tienes permisos para este recurso',
        }),
      );

      expect(result, isA<ForbiddenException>());
      expect(result.message, 'No tienes permisos para este recurso');
    });

    test('404 becomes a NotFoundException', () {
      final result = ErrorMapper.fromDio(
        _badResponse(404, {'error': 'Plato no encontrado'}),
      );

      expect(result, isA<NotFoundException>());
      expect(result.message, 'Plato no encontrado');
    });

    test('500 becomes a ServerException using mensaje over error', () {
      final result = ErrorMapper.fromDio(
        _badResponse(500, {
          'error': 'Error interno en el servidor',
          'mensaje': 'Fallo al procesar el pedido',
        }),
      );

      expect(result, isA<ServerException>());
      expect(result.message, 'Fallo al procesar el pedido');
    });

    test(
      '500 whose mensaje says Credenciales inválidas is InvalidCredentials',
      () {
        final result = ErrorMapper.fromDio(
          _badResponse(500, {
            'error': 'Error interno en el servidor',
            'mensaje': 'Credenciales inválidas',
          }),
        );

        expect(result, isA<InvalidCredentialsException>());
        expect(result.message, 'Credenciales inválidas');
      },
    );

    test('credentials detection is case-insensitive and reads message too', () {
      final upper = ErrorMapper.fromDio(
        _badResponse(500, {
          'mensaje': 'CREDENCIALES INVÁLIDAS para el usuario',
        }),
      );
      final english = ErrorMapper.fromDio(
        _badResponse(500, {'message': 'Bad credentials'}),
      );

      expect(upper, isA<InvalidCredentialsException>());
      expect(english, isA<InvalidCredentialsException>());
    });

    test('message priority is message, then mensaje, then error', () {
      expect(
        ErrorMapper.fromDio(
          _badResponse(500, {'message': 'm', 'mensaje': 'n', 'error': 'e'}),
        ).message,
        'm',
      );
      expect(
        ErrorMapper.fromDio(_badResponse(500, {'mensaje': 'n', 'error': 'e'}))
            .message,
        'n',
      );
      expect(
        ErrorMapper.fromDio(_badResponse(500, {'error': 'e'})).message,
        'e',
      );
    });

    test('blank messages are skipped', () {
      final result = ErrorMapper.fromDio(
        _badResponse(404, {'message': '   ', 'error': 'No existe'}),
      );

      expect(result.message, 'No existe');
    });

    test('a JSON string body is decoded', () {
      final result = ErrorMapper.fromDio(
        _badResponse(404, '{"error":"Mesa no encontrada"}'),
      );

      expect(result, isA<NotFoundException>());
      expect(result.message, 'Mesa no encontrada');
    });

    test('a non-JSON string body falls back to the status default', () {
      final result = ErrorMapper.fromDio(
        _badResponse(500, '<html>Internal Server Error</html>'),
      );

      expect(result, isA<ServerException>());
      expect(result.message, 'Error interno en el servidor');
    });

    test('a null body falls back to a Spanish default per status', () {
      expect(
        ErrorMapper.fromDio(_badResponse(400, null)).message,
        'Solicitud inválida',
      );
      expect(
        ErrorMapper.fromDio(_badResponse(401, null)).message,
        'Sesión inválida o expirada',
      );
      expect(
        ErrorMapper.fromDio(_badResponse(403, null)).message,
        'No tienes permisos para este recurso',
      );
      expect(
        ErrorMapper.fromDio(_badResponse(404, null)).message,
        'Recurso no encontrado',
      );
      expect(
        ErrorMapper.fromDio(_badResponse(503, null)).message,
        'Error interno en el servidor',
      );
    });

    test('other 4xx statuses become BadRequestException', () {
      expect(
        ErrorMapper.fromDio(_badResponse(422, null)),
        isA<BadRequestException>(),
      );
    });

    test('a List body is ignored defensively', () {
      final result = ErrorMapper.fromDio(_badResponse(500, ['x']));

      expect(result, isA<ServerException>());
    });
  });

  group('ErrorMapper.fromDio - transport failures', () {
    test('timeouts become RequestTimeoutException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          ErrorMapper.fromDio(_ofType(type)),
          isA<RequestTimeoutException>(),
        );
      }
    });

    test('connection errors become NetworkException', () {
      final result = ErrorMapper.fromDio(
        _ofType(DioExceptionType.connectionError),
      );

      expect(result, isA<NetworkException>());
      expect(result.message, 'No se pudo conectar con el servidor');
    });

    test(
      'an unknown error wrapping a SocketException is a NetworkException',
      () {
        final result = ErrorMapper.fromDio(
          _ofType(
            DioExceptionType.unknown,
            error: const SocketException('Failed host lookup'),
          ),
        );

        expect(result, isA<NetworkException>());
      },
    );

    test('other unknown errors become UnknownException', () {
      final result = ErrorMapper.fromDio(
        _ofType(DioExceptionType.unknown, error: StateError('boom')),
      );

      expect(result, isA<UnknownException>());
    });

    test('cancelled requests become UnknownException', () {
      expect(
        ErrorMapper.fromDio(_ofType(DioExceptionType.cancel)),
        isA<UnknownException>(),
      );
    });

    test('an AppException wrapped as the Dio error is returned untouched', () {
      const original = NotFoundException('ya mapeado');

      final result = ErrorMapper.fromDio(
        _ofType(DioExceptionType.unknown, error: original),
      );

      expect(result, same(original));
    });
  });

  group('ErrorMapper.guard', () {
    test('returns the value of the action', () async {
      expect(await ErrorMapper.guard(() async => 42), 42);
    });

    test('maps a DioException', () async {
      await expectLater(
        ErrorMapper.guard<void>(() async => throw _badResponse(404, null)),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('rethrows an AppException unchanged', () async {
      const original = ForbiddenException();

      await expectLater(
        ErrorMapper.guard<void>(() async => throw original),
        throwsA(same(original)),
      );
    });

    test('wraps a FormatException as an UnknownException', () async {
      await expectLater(
        ErrorMapper.guard<void>(() async => throw const FormatException('x')),
        throwsA(
          isA<UnknownException>().having(
            (e) => e.message,
            'message',
            'Respuesta inesperada del servidor',
          ),
        ),
      );
    });

    test('wraps any other error as an UnknownException', () async {
      await expectLater(
        ErrorMapper.guard<void>(() async => throw StateError('boom')),
        throwsA(isA<UnknownException>()),
      );
    });
  });

  group('AppException', () {
    test('default Spanish messages', () {
      expect(
        const NetworkException().message,
        'No se pudo conectar con el servidor',
      );
      expect(
        const InvalidCredentialsException().message,
        'Credenciales inválidas',
      );
      expect(
        const UnauthorizedException().message,
        'Sesión inválida o expirada',
      );
      expect(
        const ForbiddenException().message,
        'No tienes permisos para este recurso',
      );
      expect(const NotFoundException().message, 'Recurso no encontrado');
      expect(const ServerException().message, 'Error interno en el servidor');
      expect(const UnknownException().message, 'Ocurrió un error inesperado');
      expect(const RequestTimeoutException().message, isNotEmpty);
      expect(const BadRequestException().message, 'Solicitud inválida');
    });

    test('ValidationException defaults to no field errors', () {
      const exception = ValidationException('Validación fallida');

      expect(exception.fieldErrors, isEmpty);
    });

    test('toString includes the type and message', () {
      expect(const NotFoundException('x').toString(), contains('x'));
      expect(const NotFoundException('x').toString(), contains('NotFound'));
    });

    test('is an Exception', () {
      expect(const UnknownException(), isA<Exception>());
    });
  });
}
