import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/catalogo_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/categoria_plato_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/page_parser.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/plato_model.dart';

class ApiCatalogoDatasource implements CatalogoDatasource {
  const ApiCatalogoDatasource(this._dio);

  final Dio _dio;

  static const String _categorias = '/categorias-plato';
  static const String _platos = '/platos';

  static const int _categoriasPageSize = 100;

  @override
  Future<List<CategoriaPlatoModel>> getCategorias() async {
    final response = await _dio.get<dynamic>(
      _categorias,
      queryParameters: {'page': 0, 'size': _categoriasPageSize},
    );
    return parsePage(response.data, CategoriaPlatoModel.fromJson).content;
  }

  @override
  Future<CategoriaPlatoModel> createCategoria(
    CategoriaPlatoRequest request,
  ) async {
    final response = await _dio.post<dynamic>(
      _categorias,
      data: request.toJson(),
    );
    return CategoriaPlatoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<CategoriaPlatoModel> updateCategoria(
    int id,
    CategoriaPlatoRequest request,
  ) async {
    final response = await _dio.put<dynamic>(
      '$_categorias/$id',
      data: request.toJson(),
    );
    return CategoriaPlatoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<void> deleteCategoria(int id) async {
    await _dio.delete<dynamic>('$_categorias/$id');
  }

  @override
  Future<PageResult<PlatoModel>> getPlatos({int page = 0, int size = 100}) =>
      _platoPage(_platos, {'page': page, 'size': size});

  @override
  Future<PageResult<PlatoModel>> getPlatosByCategoria(
    int idCategoria, {
    int page = 0,
    int size = 100,
  }) => _platoPage('$_platos/categoria/$idCategoria', {
    'page': page,
    'size': size,
  });

  @override
  Future<PageResult<PlatoModel>> searchPlatos({
    String? nombre,
    int? idCategoria,
    bool? disponible,
    int size = 50,
  }) => _platoPage('$_platos/buscar', {
    'size': size,
    'nombre': ?nombre,
    'idCategoria': ?idCategoria,
    'disponible': ?disponible,
  });

  @override
  Future<PlatoModel> getPlato(int id) async {
    final response = await _dio.get<dynamic>('$_platos/$id');
    return PlatoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<PlatoModel> createPlato(PlatoRequest request) async {
    final response = await _dio.post<dynamic>(_platos, data: request.toJson());
    return PlatoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<PlatoModel> updatePlato(int id, PlatoRequest request) async {
    final response = await _dio.put<dynamic>(
      '$_platos/$id',
      data: request.toJson(),
    );
    return PlatoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<void> deletePlato(int id) async {
    await _dio.delete<dynamic>('$_platos/$id');
  }

  Future<PageResult<PlatoModel>> _platoPage(
    String path,
    Map<String, dynamic> query,
  ) async {
    final response = await _dio.get<dynamic>(path, queryParameters: query);
    return parsePage(response.data, PlatoModel.fromJson);
  }
}
