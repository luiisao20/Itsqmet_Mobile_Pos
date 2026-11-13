import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/usuario_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/page_parser.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/usuario_model.dart';

class ApiUsuarioDatasource implements UsuarioDatasource {
  ApiUsuarioDatasource(this._dio);

  static const _path = '/usuarios';

  final Dio _dio;

  @override
  Future<PageResult<UsuarioModel>> getUsuarios({
    int page = 0,
    int size = 100,
  }) async {
    final response = await _dio.get<dynamic>(
      _path,
      queryParameters: {'page': page, 'size': size},
    );
    return parsePage(response.data, UsuarioModel.fromJson);
  }

  @override
  Future<UsuarioModel> getUsuario(String uuid) async {
    final response = await _dio.get<dynamic>('$_path/$uuid');
    return UsuarioModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<UsuarioModel> createUsuario(UsuarioRequest request) async {
    final response = await _dio.post<dynamic>(_path, data: request.toJson());
    return UsuarioModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<UsuarioModel> updateUsuario(
    String uuid,
    UsuarioRequest request,
  ) async {
    final response = await _dio.put<dynamic>(
      '$_path/$uuid',
      data: request.toJson(),
    );
    return UsuarioModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<void> deleteUsuario(String uuid) async {
    await _dio.delete<dynamic>('$_path/$uuid');
  }
}
