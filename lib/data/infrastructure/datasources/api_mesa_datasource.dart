import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/mesa_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/estado_mesa.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/mesa_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/page_parser.dart';

class ApiMesaDatasource implements MesaDatasource {
  const ApiMesaDatasource(this._dio);

  final Dio _dio;

  static const String _mesas = '/mesas';

  @override
  Future<PageResult<MesaModel>> getMesas({int page = 0, int size = 100}) async {
    final response = await _dio.get<dynamic>(
      _mesas,
      queryParameters: {'page': page, 'size': size},
    );
    return parsePage(response.data, MesaModel.fromJson);
  }

  @override
  Future<MesaModel> getMesa(int id) async {
    final response = await _dio.get<dynamic>('$_mesas/$id');
    return MesaModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<MesaModel> createMesa(MesaRequest request) async {
    final response = await _dio.post<dynamic>(_mesas, data: request.toJson());
    return MesaModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<MesaModel> updateMesa(int id, MesaRequest request) async {
    final response = await _dio.put<dynamic>(
      '$_mesas/$id',
      data: request.toJson(),
    );
    return MesaModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<void> deleteMesa(int id) async {
    await _dio.delete<dynamic>('$_mesas/$id');
  }

  @override
  Future<MesaModel> updateEstado(int id, EstadoMesa estado) async {
    final response = await _dio.patch<dynamic>(
      '$_mesas/$id/estado',
      queryParameters: {'estado': estado.toJson()},
    );
    return MesaModel.fromJson(asJsonMap(response.data));
  }
}
