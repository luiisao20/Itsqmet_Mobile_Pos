import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/distribuidor_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/distribuidor_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/page_parser.dart';

class ApiDistribuidorDatasource implements DistribuidorDatasource {
  ApiDistribuidorDatasource(this._dio);

  static const _path = '/distribuidores';

  final Dio _dio;

  @override
  Future<PageResult<DistribuidorModel>> getDistribuidores({
    int page = 0,
    int size = 100,
  }) async {
    final response = await _dio.get<dynamic>(
      _path,
      queryParameters: {'page': page, 'size': size},
    );
    return parsePage(response.data, DistribuidorModel.fromJson);
  }

  @override
  Future<DistribuidorModel> createDistribuidor(
    DistribuidorRequest request,
  ) async {
    final response = await _dio.post<dynamic>(_path, data: request.toJson());
    return DistribuidorModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<DistribuidorModel> updateDistribuidor(
    int id,
    DistribuidorRequest request,
  ) async {
    final response = await _dio.put<dynamic>(
      '$_path/$id',
      data: request.toJson(),
    );
    return DistribuidorModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<void> deleteDistribuidor(int id) async {
    await _dio.delete<dynamic>('$_path/$id');
  }
}
