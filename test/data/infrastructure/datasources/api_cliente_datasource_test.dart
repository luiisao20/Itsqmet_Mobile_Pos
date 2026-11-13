import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/datasources/api_cliente_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_dio.dart';

const _clienteJson = {
  'uuid': 'c-1',
  'tipoIdentificacion': 'CEDULA',
  'identificacion': '1712345678',
  'razonSocial': 'Juan Cliente',
  'direccion': 'Quito',
  'telefono': '0999999999',
  'email': 'juan@x.com',
  'activo': true,
  'createdAt': 1768473000000,
};

const _request = ClienteRequest(
  tipoIdentificacion: TipoIdentificacion.ruc,
  identificacion: '1790012345001',
  razonSocial: 'Empresa S.A.',
  email: 'empresa@x.com',
);

const _requestJson = {
  'tipoIdentificacion': 'RUC',
  'identificacion': '1790012345001',
  'razonSocial': 'Empresa S.A.',
  'email': 'empresa@x.com',
};

void main() {
  late MockDio dio;
  late ApiClienteDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = ApiClienteDatasource(dio);
  });

  group('getClientes', () {
    test('GETs /clientes with page and size and parses the page', () async {
      when(
        () => dio.get<dynamic>(
          '/clientes',
          queryParameters: {'page': 1, 'size': 20},
        ),
      ).thenAnswer((_) async => okResponse(pageJson([_clienteJson])));

      final page = await datasource.getClientes(page: 1, size: 20);

      final cliente = page.content.single;
      expect(cliente.uuid, 'c-1');
      expect(cliente.tipoIdentificacion, TipoIdentificacion.cedula);
      expect(cliente.direccion, 'Quito');
      expect(
        cliente.createdAt,
        DateTime.fromMillisecondsSinceEpoch(1768473000000),
      );
    });

    test('uses page 0 and size 100 by default', () async {
      when(
        () => dio.get<dynamic>(
          '/clientes',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).thenAnswer((_) async => okResponse(pageJson(const [])));

      final page = await datasource.getClientes();

      expect(page.content, isEmpty);
    });
  });

  test('getCliente GETs /clientes/{uuid}', () async {
    when(() => dio.get<dynamic>('/clientes/c-1'))
        .thenAnswer((_) async => okResponse(_clienteJson));

    final cliente = await datasource.getCliente('c-1');

    expect(cliente.razonSocial, 'Juan Cliente');
  });

  test('getByIdentificacion GETs /clientes/identificacion/{id}', () async {
    when(() => dio.get<dynamic>('/clientes/identificacion/1712345678'))
        .thenAnswer((_) async => okResponse(_clienteJson));

    final cliente = await datasource.getByIdentificacion('1712345678');

    expect(cliente.identificacion, '1712345678');
  });

  group('searchClientes', () {
    test('GETs /clientes/buscar with filtro, page and size', () async {
      when(
        () => dio.get<dynamic>(
          '/clientes/buscar',
          queryParameters: {'filtro': 'juan', 'page': 1, 'size': 5},
        ),
      ).thenAnswer((_) async => okResponse(pageJson([_clienteJson])));

      final page = await datasource.searchClientes('juan', page: 1, size: 5);

      expect(page.content.single.uuid, 'c-1');
    });

    test('uses page 0 and size 50 by default and accepts an array', () async {
      when(
        () => dio.get<dynamic>(
          '/clientes/buscar',
          queryParameters: {'filtro': '171', 'page': 0, 'size': 50},
        ),
      ).thenAnswer((_) async => okResponse([_clienteJson]));

      final page = await datasource.searchClientes('171');

      expect(page.content.single.identificacion, '1712345678');
      expect(page.totalElements, 1);
    });
  });

  test('createCliente POSTs /clientes with the request body', () async {
    when(() => dio.post<dynamic>('/clientes', data: _requestJson))
        .thenAnswer((_) async => okResponse(_clienteJson, status: 201));

    final cliente = await datasource.createCliente(_request);

    expect(cliente.uuid, 'c-1');
    verify(() => dio.post<dynamic>('/clientes', data: _requestJson)).called(1);
  });

  test('updateCliente PUTs /clientes/{uuid} with the request body', () async {
    when(() => dio.put<dynamic>('/clientes/c-1', data: _requestJson))
        .thenAnswer((_) async => okResponse(_clienteJson));

    final cliente = await datasource.updateCliente('c-1', _request);

    expect(cliente.uuid, 'c-1');
    verify(() => dio.put<dynamic>('/clientes/c-1', data: _requestJson))
        .called(1);
  });

  test('deleteCliente DELETEs /clientes/{uuid} (204)', () async {
    when(() => dio.delete<dynamic>('/clientes/c-1'))
        .thenAnswer((_) async => okResponse(null, status: 204));

    await datasource.deleteCliente('c-1');

    verify(() => dio.delete<dynamic>('/clientes/c-1')).called(1);
  });

  test('lets DioException propagate unmapped', () async {
    when(() => dio.delete<dynamic>('/clientes/c-1'))
        .thenThrow(connectionFailure());

    await expectLater(
      datasource.deleteCliente('c-1'),
      throwsA(isA<DioException>()),
    );
  });
}
