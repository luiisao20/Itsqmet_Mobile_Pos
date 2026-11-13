import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/datasources/api_pedido_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_dio.dart';

Map<String, dynamic> _pedidoJson({
  int id = 50,
  String estado = 'ABIERTO',
  Object? fechaApertura = '2026-05-01T12:30:00Z',
}) => {
  'id': id,
  'idMesa': 3,
  'numeroMesa': 3,
  'idUsuario': 'u-1',
  'nombreUsuario': 'Ana Pérez',
  'fechaApertura': fechaApertura,
  'estado': estado,
  'tipo': 'SALON',
  'detalles': [
    {
      'id': 100,
      'idPedido': id,
      'idPlato': 10,
      'nombrePlato': 'Ceviche',
      'cantidad': 2,
      'precioUnitario': 8.5,
      'subtotal': 17,
      'estado': 'PENDIENTE',
    },
  ],
};

void main() {
  late MockDio dio;
  late ApiPedidoDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = ApiPedidoDatasource(dio);
  });

  group('getPedidos', () {
    test('GETs /pedidos with page and size and parses the Page', () async {
      when(
        () => dio.get<dynamic>(
          '/pedidos',
          queryParameters: {'page': 2, 'size': 30},
        ),
      ).thenAnswer(
        (_) async => okResponse({
          ...pageJson([_pedidoJson()]),
          'number': 2,
          'totalElements': 61,
          'totalPages': 3,
          'last': true,
          'first': false,
        }),
      );

      final page = await datasource.getPedidos(page: 2, size: 30);

      expect(page.number, 2);
      expect(page.totalElements, 61);
      expect(page.content.single.id, 50);
      expect(page.content.single.estado, EstadoPedido.abierto);
      expect(page.content.single.detalles.single.nombrePlato, 'Ceviche');
      expect(
        page.content.single.fechaApertura?.toUtc(),
        DateTime.utc(2026, 5, 1, 12, 30),
      );
    });

    test('sends the default page 0 / size 50', () async {
      when(
        () => dio.get<dynamic>(
          '/pedidos',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => okResponse(pageJson([])));

      final page = await datasource.getPedidos();

      expect(page.content, isEmpty);
      verify(
        () => dio.get<dynamic>(
          '/pedidos',
          queryParameters: {'page': 0, 'size': 50},
        ),
      ).called(1);
    });

    test('lets DioException propagate', () async {
      when(
        () => dio.get<dynamic>(
          '/pedidos',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(httpError(500));

      await expectLater(datasource.getPedidos(), throwsA(isA<DioException>()));
    });
  });

  group('getPedido', () {
    test('GETs /pedidos/{id} and parses epoch dates', () async {
      when(() => dio.get<dynamic>('/pedidos/50')).thenAnswer(
        (_) async => okResponse(
          _pedidoJson(
            fechaApertura: DateTime.utc(2026, 5, 1).millisecondsSinceEpoch,
          ),
        ),
      );

      final pedido = await datasource.getPedido(50);

      expect(pedido.id, 50);
      expect(pedido.fechaApertura?.toUtc(), DateTime.utc(2026, 5, 1));
    });
  });

  group('searchPedidos', () {
    test('GETs /pedidos/buscar with every filter', () async {
      when(
        () => dio.get<dynamic>(
          '/pedidos/buscar',
          queryParameters: {
            'size': 20,
            'estado': 'EN_PREPARACION',
            'tipo': 'LLEVAR',
            'idMesa': 3,
          },
        ),
      ).thenAnswer(
        (_) async =>
            okResponse(pageJson([_pedidoJson(estado: 'EN_PREPARACION')])),
      );

      final page = await datasource.searchPedidos(
        estado: EstadoPedido.enPreparacion,
        tipo: TipoPedido.llevar,
        idMesa: 3,
        size: 20,
      );

      expect(page.content.single.estado, EstadoPedido.enPreparacion);
    });

    test('omits null filters', () async {
      when(
        () => dio.get<dynamic>(
          '/pedidos/buscar',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => okResponse(pageJson([])));

      await datasource.searchPedidos();

      final captured =
          verify(
                () => dio.get<dynamic>(
                  '/pedidos/buscar',
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured, {'size': 50});
    });

    test('accepts a plain array response', () async {
      when(
        () => dio.get<dynamic>(
          '/pedidos/buscar',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => okResponse([_pedidoJson(), _pedidoJson(id: 51)]),
      );

      final page = await datasource.searchPedidos(idMesa: 3);

      expect(page.content.map((p) => p.id), [50, 51]);
      expect(page.totalElements, 2);
    });
  });

  group('createPedido', () {
    test('POSTs /pedidos with the request body', () async {
      const request = PedidoRequest(
        idMesa: 3,
        tipo: TipoPedido.salon,
        detalles: [
          DetallePedidoRequest(
            idPlato: 10,
            cantidad: 2,
            notasPreparacion: 'Sin cebolla',
          ),
        ],
      );
      when(() => dio.post<dynamic>('/pedidos', data: any(named: 'data')))
          .thenAnswer((_) async => okResponse(_pedidoJson(), status: 201));

      final pedido = await datasource.createPedido(request);

      expect(pedido.id, 50);
      verify(() => dio.post<dynamic>('/pedidos', data: request.toJson()))
          .called(1);
      expect(request.toJson().containsKey('idCliente'), isFalse);
    });
  });

  group('createPedidoCliente', () {
    test('POSTs /pedidos/cliente with the request body', () async {
      const request = PedidoClienteRequest(
        observaciones: 'Rápido',
        detalles: [DetallePedidoRequest(idPlato: 10, cantidad: 1)],
      );
      when(
        () => dio.post<dynamic>('/pedidos/cliente', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse(_pedidoJson(), status: 201));

      final pedido = await datasource.createPedidoCliente(request);

      expect(pedido.id, 50);
      verify(
        () => dio.post<dynamic>('/pedidos/cliente', data: request.toJson()),
      ).called(1);
    });
  });

  group('updateEstado', () {
    test('PATCHes /pedidos/{id}/estado with the estado query param', () async {
      when(
        () => dio.patch<dynamic>(
          '/pedidos/50/estado',
          queryParameters: {'estado': 'SERVIDO'},
        ),
      ).thenAnswer((_) async => okResponse(_pedidoJson(estado: 'SERVIDO')));

      final pedido = await datasource.updateEstado(50, EstadoPedido.servido);

      expect(pedido.estado, EstadoPedido.servido);
      verify(
        () => dio.patch<dynamic>(
          '/pedidos/50/estado',
          queryParameters: {'estado': 'SERVIDO'},
        ),
      ).called(1);
    });
  });

  group('getMisPedidos', () {
    test('GETs /pedidos/mis-pedidos with page and size', () async {
      when(
        () => dio.get<dynamic>(
          '/pedidos/mis-pedidos',
          queryParameters: {'page': 1, 'size': 20},
        ),
      ).thenAnswer((_) async => okResponse(pageJson([_pedidoJson()])));

      final page = await datasource.getMisPedidos(page: 1, size: 20);

      expect(page.content.single.id, 50);
    });
  });
}
