import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/datasources/api_insumo_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_dio.dart';

const _insumoJson = {
  'id': 4,
  'nombre': 'Arroz',
  'unidadMedida': 'KG',
  'stockActual': '3.5',
  'stockMinimo': 5,
  'costoPromedio': 1.2,
  'stockBajo': true,
};

const _request = InsumoRequest(
  nombre: 'Arroz',
  unidadMedida: UnidadMedida.kg,
  stockActual: 10,
  stockMinimo: 5,
  costoPromedio: 1.2,
);

const _requestJson = {
  'nombre': 'Arroz',
  'unidadMedida': 'KG',
  'stockActual': 10.0,
  'stockMinimo': 5.0,
  'costoPromedio': 1.2,
};

void main() {
  late MockDio dio;
  late ApiInsumoDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = ApiInsumoDatasource(dio);
  });

  group('getInsumos', () {
    test('GETs /insumos with page and size and parses the page', () async {
      when(
        () => dio.get<dynamic>(
          '/insumos',
          queryParameters: {'page': 3, 'size': 25},
        ),
      ).thenAnswer((_) async => okResponse(pageJson([_insumoJson])));

      final page = await datasource.getInsumos(page: 3, size: 25);

      final insumo = page.content.single;
      expect(insumo.id, 4);
      expect(insumo.unidadMedida, UnidadMedida.kg);
      expect(insumo.stockActual, 3.5);
      expect(insumo.stockBajo, isTrue);
    });

    test('uses page 0 and size 100 by default', () async {
      when(
        () => dio.get<dynamic>(
          '/insumos',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).thenAnswer((_) async => okResponse(pageJson(const [])));

      final page = await datasource.getInsumos();

      expect(page.content, isEmpty);
    });
  });

  group('getStockBajo', () {
    test('GETs /insumos/stock-bajo and unwraps the Spring page', () async {
      when(
        () => dio.get<dynamic>(
          '/insumos/stock-bajo',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).thenAnswer((_) async => okResponse(pageJson([_insumoJson])));

      final insumos = await datasource.getStockBajo();

      expect(insumos, hasLength(1));
      expect(insumos.single.nombre, 'Arroz');
    });

    test('accepts a plain array', () async {
      when(
        () => dio.get<dynamic>(
          '/insumos/stock-bajo',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => okResponse([
          _insumoJson,
          {..._insumoJson, 'id': 5},
        ]),
      );

      final insumos = await datasource.getStockBajo();

      expect(insumos.map((i) => i.id), [4, 5]);
    });
  });

  test('createInsumo POSTs /insumos with the request body', () async {
    when(() => dio.post<dynamic>('/insumos', data: _requestJson))
        .thenAnswer((_) async => okResponse(_insumoJson, status: 201));

    final insumo = await datasource.createInsumo(_request);

    expect(insumo.id, 4);
    verify(() => dio.post<dynamic>('/insumos', data: _requestJson)).called(1);
  });

  test('updateInsumo PUTs /insumos/{id} with the request body', () async {
    when(() => dio.put<dynamic>('/insumos/4', data: _requestJson))
        .thenAnswer((_) async => okResponse(_insumoJson));

    final insumo = await datasource.updateInsumo(4, _request);

    expect(insumo.nombre, 'Arroz');
    verify(() => dio.put<dynamic>('/insumos/4', data: _requestJson)).called(1);
  });

  test('deleteInsumo DELETEs /insumos/{id} (204)', () async {
    when(() => dio.delete<dynamic>('/insumos/4'))
        .thenAnswer((_) async => okResponse(null, status: 204));

    await datasource.deleteInsumo(4);

    verify(() => dio.delete<dynamic>('/insumos/4')).called(1);
  });

  test('lets DioException propagate unmapped', () async {
    when(() => dio.post<dynamic>('/insumos', data: any(named: 'data')))
        .thenThrow(httpError(400, {'error': 'Validación fallida'}));

    await expectLater(
      datasource.createInsumo(_request),
      throwsA(isA<DioException>()),
    );
  });
}
