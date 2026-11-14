import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/paquete_sorpresa_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/paquete_sorpresa_model.dart';

class ApiPaqueteSorpresaDatasource implements PaqueteSorpresaDatasource {
  const ApiPaqueteSorpresaDatasource(this._dio);

  final Dio _dio;

  static const String _path = '/paquetes-sorpresa';

  @override
  Future<List<PaqueteSorpresaModel>> getDisponibles() async {
    final response = await _dio.get<dynamic>('$_path/disponibles');
    return asJsonMapList(response.data)
        .map(PaqueteSorpresaModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<RescateResultModel> rescatar(
    int id, {
    int cantidad = 1,
    String? observaciones,
  }) async {
    final response = await _dio.post<dynamic>(
      '$_path/$id/rescatar',
      data: {
        'cantidad': cantidad,
        if (observaciones != null && observaciones.trim().isNotEmpty)
          'observaciones': observaciones.trim(),
      },
    );
    return RescateResultModel.fromJson(asJsonMap(response.data));
  }
}
