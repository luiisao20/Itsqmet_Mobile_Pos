import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/pedido_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/estado_pedido.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/tipo_pedido.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/page_parser.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pedido_model.dart';

class ApiPedidoDatasource implements PedidoDatasource {
  ApiPedidoDatasource(this._dio);

  final Dio _dio;

  static const _path = '/pedidos';

  @override
  Future<PageResult<PedidoModel>> getPedidos({
    int page = 0,
    int size = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      _path,
      queryParameters: {'page': page, 'size': size},
    );
    return parsePage(response.data, PedidoModel.fromJson);
  }

  @override
  Future<PedidoModel> getPedido(int id) async {
    final response = await _dio.get<dynamic>('$_path/$id');
    return PedidoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<PageResult<PedidoModel>> searchPedidos({
    EstadoPedido? estado,
    TipoPedido? tipo,
    int? idMesa,
    int size = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '$_path/buscar',
      queryParameters: {
        'size': size,
        if (estado != null) 'estado': estado.toJson(),
        if (tipo != null) 'tipo': tipo.toJson(),
        'idMesa': ?idMesa,
      },
    );
    return parsePage(response.data, PedidoModel.fromJson);
  }

  @override
  Future<PedidoModel> createPedido(PedidoRequest request) async {
    final response = await _dio.post<dynamic>(_path, data: request.toJson());
    return PedidoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<PedidoModel> createPedidoCliente(PedidoClienteRequest request) async {
    final response = await _dio.post<dynamic>(
      '$_path/cliente',
      data: request.toJson(),
    );
    return PedidoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<PedidoModel> updateEstado(int id, EstadoPedido estado) async {
    final response = await _dio.patch<dynamic>(
      '$_path/$id/estado',
      queryParameters: {'estado': estado.toJson()},
    );
    return PedidoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<PageResult<PedidoModel>> getMisPedidos({
    int page = 0,
    int size = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '$_path/mis-pedidos',
      queryParameters: {'page': page, 'size': size},
    );
    return parsePage(response.data, PedidoModel.fromJson);
  }
}
