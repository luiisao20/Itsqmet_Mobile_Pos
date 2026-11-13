import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/errors/app_exception.dart';
import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/core/network/cookie_token_extractor.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/auth_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/auth_model.dart';

class ApiAuthDatasource implements AuthDatasource {
  const ApiAuthDatasource(this._dio);

  final Dio _dio;

  @override
  Future<AuthSessionModel> loginStaff(LoginRequest request) =>
      _session('/auth/login', request.toJson());

  @override
  Future<AuthSessionModel> loginCliente(ClienteLoginRequest request) =>
      _session('/auth/cliente/login', request.toJson());

  @override
  Future<AuthSessionModel> registerCliente(
    ClienteRegistrationRequest request,
  ) => _session('/auth/cliente/registro', request.toJson());

  @override
  Future<AuthResponseModel> me() => ErrorMapper.guard(() async {
    final response = await _dio.get<dynamic>('/auth/me');
    return AuthResponseModel.fromJson(asJsonMap(response.data));
  });

  @override
  Future<void> logout() => ErrorMapper.guard(() async {
    await _dio.post<dynamic>('/auth/logout');
  });

  Future<AuthSessionModel> _session(String path, Map<String, dynamic> body) {
    return ErrorMapper.guard(() async {
      final response = await _dio.post<dynamic>(path, data: body);
      final json = asJsonMap(response.data);
      final token =
          CookieTokenExtractor.extractJwt(response.headers) ??
          parseString(json['token']);
      if (token == null || token.isEmpty) {
        throw const UnknownException('No se recibió el token de sesión');
      }
      return AuthSessionModel(
        user: AuthResponseModel.fromJson(json),
        token: token,
      );
    });
  }
}
