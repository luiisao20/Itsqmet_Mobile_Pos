sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No se pudo conectar con el servidor',
  ]);
}

final class RequestTimeoutException extends AppException {
  const RequestTimeoutException([
    super.message = 'El servidor tardó demasiado en responder',
  ]);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Sesión inválida o expirada']);
}

final class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'No tienes permisos para este recurso',
  ]);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Recurso no encontrado']);
}

final class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.fieldErrors = const <String, String>{},
  });

  final Map<String, String> fieldErrors;
}

final class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Solicitud inválida']);
}

final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([super.message = 'Credenciales inválidas']);
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Error interno en el servidor']);
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'Ocurrió un error inesperado']);
}
