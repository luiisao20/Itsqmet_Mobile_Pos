import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';

abstract final class ErrorMapper {
  static AppException fromDio(DioException error) {
    final wrapped = error.error;
    if (wrapped is AppException) return wrapped;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const RequestTimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const UnknownException('La solicitud fue cancelada');
      case DioExceptionType.badCertificate:
        return const NetworkException(
          'No se pudo establecer una conexión segura con el servidor',
        );
      case DioExceptionType.badResponse:
        return _fromResponse(error.response);
      case DioExceptionType.unknown:
        if (wrapped is SocketException) return const NetworkException();
        if (error.response != null) return _fromResponse(error.response);
        return const UnknownException();
    }
  }

  static Future<T> guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw fromDio(error);
    } on FormatException {
      throw const UnknownException('Respuesta inesperada del servidor');
    } on TypeError {
      throw const UnknownException('Respuesta inesperada del servidor');
    } catch (_) {
      throw const UnknownException();
    }
  }

  static AppException _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final body = _bodyAsMap(response?.data);
    final message = _extractMessage(body);

    if (_isInvalidCredentials(body) && (status == 401 || status >= 500)) {
      return const InvalidCredentialsException();
    }

    if (status == 400) {
      final detalles = body?['detalles'];
      if (detalles is Map) {
        return ValidationException(
          message ?? 'Validación fallida',
          fieldErrors: _fieldErrors(detalles),
        );
      }
      return BadRequestException(message ?? 'Solicitud inválida');
    }
    if (status == 401) {
      return UnauthorizedException(message ?? 'Sesión inválida o expirada');
    }
    if (status == 403) {
      return ForbiddenException(
        message ?? 'No tienes permisos para este recurso',
      );
    }
    if (status == 404) {
      return NotFoundException(message ?? 'Recurso no encontrado');
    }
    if (status >= 500) {
      return ServerException(message ?? 'Error interno en el servidor');
    }
    if (status >= 400) {
      return BadRequestException(message ?? 'Solicitud inválida');
    }
    return UnknownException(message ?? 'Ocurrió un error inesperado');
  }

  static Map<String, dynamic>? _bodyAsMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  static String? _extractMessage(Map<String, dynamic>? body) {
    if (body == null) return null;
    for (final key in const ['message', 'mensaje', 'error']) {
      final value = body[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static bool _isInvalidCredentials(Map<String, dynamic>? body) {
    if (body == null) return false;
    for (final key in const ['message', 'mensaje', 'error']) {
      final value = body[key];
      if (value is! String) continue;
      final text = value.toLowerCase();
      if (text.contains('credenciales inválidas') ||
          text.contains('credenciales invalidas') ||
          text.contains('bad credentials')) {
        return true;
      }
    }
    return false;
  }

  static Map<String, String> _fieldErrors(Map<dynamic, dynamic> detalles) {
    final result = <String, String>{};
    detalles.forEach((key, value) {
      if (value == null) return;
      result[key.toString()] = value.toString();
    });
    return result;
  }
}
