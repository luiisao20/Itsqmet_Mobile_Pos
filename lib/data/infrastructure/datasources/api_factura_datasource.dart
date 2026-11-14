import 'package:dio/dio.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/factura_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/factura_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/page_parser.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pago_model.dart';

class ApiFacturaDatasource implements FacturaDatasource {
  ApiFacturaDatasource(this._dio);

  final Dio _dio;

  static const _facturas = '/facturas';
  static const _pagos = '/pagos';

  @override
  Future<PageResult<FacturaModel>> getFacturas({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get<dynamic>(
      _facturas,
      queryParameters: {'page': page, 'size': size},
    );
    return parsePage(response.data, FacturaModel.fromJson);
  }

  @override
  Future<PageResult<FacturaModel>> searchFacturas({
    String? clienteFiltro,
    String? secuencial,
    int page = 0,
    int size = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '$_facturas/buscar',
      queryParameters: {
        'page': page,
        'size': size,
        if (clienteFiltro != null && clienteFiltro.trim().isNotEmpty)
          'clienteFiltro': clienteFiltro.trim(),
        if (secuencial != null && secuencial.trim().isNotEmpty)
          'secuencial': secuencial.trim(),
      },
    );
    return parsePage(response.data, FacturaModel.fromJson);
  }

  @override
  Future<FacturaModel> getFactura(int id) async {
    final response = await _dio.get<dynamic>('$_facturas/$id');
    return FacturaModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<PageResult<FacturaModel>> getMisFacturas({
    int page = 0,
    int size = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '$_facturas/mis-facturas',
      queryParameters: {'page': page, 'size': size},
    );
    return parsePage(response.data, FacturaModel.fromJson);
  }

  @override
  Future<FacturaModel> emitirFactura(FacturaRequest request) async {
    final response = await _dio.post<dynamic>(
      _facturas,
      data: request.toJson(),
    );
    return FacturaModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<PagoModel> registrarPago(PagoRequest request) async {
    final response = await _dio.post<dynamic>(_pagos, data: request.toJson());
    return PagoModel.fromJson(asJsonMap(response.data));
  }

  @override
  Future<List<PagoModel>> getPagosByFactura(int idFactura) async {
    final response = await _dio.get<dynamic>(
      '$_pagos/factura/$idFactura',
      queryParameters: {'page': 0, 'size': 100},
    );
    return parsePage(response.data, PagoModel.fromJson).content;
  }
}
