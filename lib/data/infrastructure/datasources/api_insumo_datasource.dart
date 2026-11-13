import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/insumo_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/insumo_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/page_parser.dart';

class ApiInsumoDatasource implements InsumoDatasource {
  ApiInsumoDatasource(this._dio);

  static const _path = '/insumos';

  static const _stockBajoPageSize = 100;

  final Dio _dio;

  @override
  Future<PageResult<InsumoModel>> getInsumos({
    int page = 0,
    int size = 100,
  }) async {
    final response = await _dio.get<dynamic>(
      _path,
      queryParameters: {'page': page, 'size': size},
    );
    return parsePage(response.data, InsumoModel.fromJson);
  }

  @override
  Future<List<InsumoModel>> getStockBajo() async {
    final response = await _dio.get<dynamic>(
      '$_path/stock-bajo',
      queryParameters: {'page': 0, 'size': _stockBajoPageSize},
    );
    return parsePage(response.data, InsumoModel.fromJson).content;
  }

  @override
  Future<InsumoModel> createInsumo(InsumoRequest request) async {
    final response = await _dio.post<dynamic>(_path, data: request.toJson());
    return InsumoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<InsumoModel> updateInsumo(int id, InsumoRequest request) async {
    final response = await _dio.put<dynamic>(
      '$_path/$id',
      data: request.toJson(),
    );
    return InsumoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<void> deleteInsumo(int id) async {
    await _dio.delete<dynamic>('$_path/$id');
  }
}
