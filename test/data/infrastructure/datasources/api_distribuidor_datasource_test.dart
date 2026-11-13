import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/datasources/api_distribuidor_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_dio.dart';

const _distribuidorJson = {
  'id': 2,
  'ruc': '1790012345001',
  'razonSocial': 'Distribuidora S.A.',
  'nombreContacto': 'Luis',
  'telefono': '022222222',
  'email': 'ventas@dist.com',
  'direccion': 'Quito',
  'categoriaProveedor': 'Abarrotes',
  'createdAt': '2026-02-01T08:00:00',
};

const _request = DistribuidorRequest(
  ruc: '1790012345001',
  razonSocial: 'Distribuidora S.A.',
  nombreContacto: 'Luis',
  categoriaProveedor: 'Abarrotes',
);

const _requestJson = {
  'ruc': '1790012345001',
  'razonSocial': 'Distribuidora S.A.',
  'nombreContacto': 'Luis',
  'categoriaProveedor': 'Abarrotes',
};

void main() {
  late MockDio dio;
  late ApiDistribuidorDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = ApiDistribuidorDatasource(dio);
  });

  group('getDistribuidores', () {
    test(
      'GETs /distribuidores with page and size and parses the page',
      () async {
        when(
          () => dio.get<dynamic>(
            '/distribuidores',
            queryParameters: {'page': 1, 'size': 30},
          ),
        ).thenAnswer((_) async => okResponse(pageJson([_distribuidorJson])));

        final page = await datasource.getDistribuidores(page: 1, size: 30);

        final distribuidor = page.content.single;
        expect(distribuidor.id, 2);
        expect(distribuidor.ruc, '1790012345001');
        expect(distribuidor.nombreContacto, 'Luis');
        expect(distribuidor.createdAt, DateTime(2026, 2, 1, 8));
      },
    );

    test('uses page 0 and size 100 by default', () async {
      when(
        () => dio.get<dynamic>(
          '/distribuidores',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).thenAnswer((_) async => okResponse(pageJson(const [])));

      final page = await datasource.getDistribuidores();

      expect(page.content, isEmpty);
    });
  });

  test('createDistribuidor POSTs /distribuidores with the body', () async {
    when(() => dio.post<dynamic>('/distribuidores', data: _requestJson))
        .thenAnswer((_) async => okResponse(_distribuidorJson, status: 201));

    final distribuidor = await datasource.createDistribuidor(_request);

    expect(distribuidor.id, 2);
    verify(() => dio.post<dynamic>('/distribuidores', data: _requestJson))
        .called(1);
  });

  test('updateDistribuidor PUTs /distribuidores/{id} with the body', () async {
    when(() => dio.put<dynamic>('/distribuidores/2', data: _requestJson))
        .thenAnswer((_) async => okResponse(_distribuidorJson));

    final distribuidor = await datasource.updateDistribuidor(2, _request);

    expect(distribuidor.razonSocial, 'Distribuidora S.A.');
    verify(() => dio.put<dynamic>('/distribuidores/2', data: _requestJson))
        .called(1);
  });

  test('deleteDistribuidor DELETEs /distribuidores/{id} (204)', () async {
    when(() => dio.delete<dynamic>('/distribuidores/2'))
        .thenAnswer((_) async => okResponse(null, status: 204));

    await datasource.deleteDistribuidor(2);

    verify(() => dio.delete<dynamic>('/distribuidores/2')).called(1);
  });

  test('lets DioException propagate unmapped', () async {
    when(() => dio.put<dynamic>('/distribuidores/9', data: any(named: 'data')))
        .thenThrow(httpError(404));

    await expectLater(
      datasource.updateDistribuidor(9, _request),
      throwsA(isA<DioException>()),
    );
  });
}
