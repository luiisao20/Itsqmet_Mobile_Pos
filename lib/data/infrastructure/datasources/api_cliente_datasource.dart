import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/cliente_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/cliente_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/page_parser.dart';

class ApiClienteDatasource implements ClienteDatasource {
  ApiClienteDatasource(this._dio);

  static const _path = '/clientes';

  final Dio _dio;

  @override
  Future<PageResult<ClienteModel>> getClientes({
    int page = 0,
    int size = 100,
  }) async {
    final response = await _dio.get<dynamic>(
      _path,
      queryParameters: {'page': page, 'size': size},
    );
    return parsePage(response.data, ClienteModel.fromJson);
  }

  @override
  Future<ClienteModel> getCliente(String uuid) async {
    final response = await _dio.get<dynamic>('$_path/$uuid');
    return ClienteModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<ClienteModel> getByIdentificacion(String identificacion) async {
    final response = await _dio.get<dynamic>(
      '$_path/identificacion/${Uri.encodeComponent(identificacion)}',
    );
    return ClienteModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<PageResult<ClienteModel>> searchClientes(
    String filtro, {
    int page = 0,
    int size = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '$_path/buscar',
      queryParameters: {'filtro': filtro, 'page': page, 'size': size},
    );
    return parsePage(response.data, ClienteModel.fromJson);
  }

  @override
  Future<ClienteModel> createCliente(ClienteRequest request) async {
    final response = await _dio.post<dynamic>(_path, data: request.toJson());
    return ClienteModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<ClienteModel> updateCliente(
    String uuid,
    ClienteRequest request,
  ) async {
    final response = await _dio.put<dynamic>(
      '$_path/$uuid',
      data: request.toJson(),
    );
    return ClienteModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<void> deleteCliente(String uuid) async {
    await _dio.delete<dynamic>('$_path/$uuid');
  }
}
