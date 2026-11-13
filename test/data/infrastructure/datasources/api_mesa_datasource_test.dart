import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/datasources/api_mesa_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_dio.dart';

const _mesaJson = {
  'id': 3,
  'numeroMesa': 3,
  'capacidad': 4,
  'ubicacion': 'Terraza',
  'estado': 'LIBRE',
  'createdAt': 1736510400000,
};

void main() {
  late MockDio dio;
  late ApiMesaDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = ApiMesaDatasource(dio);
  });

  test('getMesas GETs /mesas with page and size (defaults 0/100)', () async {
    when(
      () =>
          dio.get<dynamic>('/mesas', queryParameters: {'page': 0, 'size': 100}),
    ).thenAnswer((_) async => okResponse(pageJson([_mesaJson])));

    final page = await datasource.getMesas();

    expect(page.totalElements, 1);
    final mesa = page.content.single;
    expect(mesa.id, 3);
    expect(mesa.numeroMesa, 3);
    expect(mesa.capacidad, 4);
    expect(mesa.ubicacion, 'Terraza');
    expect(mesa.estado, EstadoMesa.libre);
    expect(mesa.createdAt, isNotNull);
  });

  test('getMesas forwards custom paging', () async {
    when(
      () =>
          dio.get<dynamic>('/mesas', queryParameters: {'page': 1, 'size': 10}),
    ).thenAnswer((_) async => okResponse([_mesaJson]));

    final page = await datasource.getMesas(page: 1, size: 10);

    expect(page.content.single.id, 3);
  });

  test('getMesa GETs /mesas/{id}', () async {
    when(
      () => dio.get<dynamic>('/mesas/3'),
    ).thenAnswer((_) async => okResponse({..._mesaJson, 'estado': 'OCUPADA'}));

    final mesa = await datasource.getMesa(3);

    expect(mesa.estado, EstadoMesa.ocupada);
  });

  test('createMesa POSTs /mesas with the request body', () async {
    when(
      () => dio.post<dynamic>(
        '/mesas',
        data: {'numeroMesa': 8, 'capacidad': 2, 'estado': 'LIBRE'},
      ),
    ).thenAnswer(
      (_) async => okResponse({
        ..._mesaJson,
        'id': 8,
        'numeroMesa': 8,
        'capacidad': 2,
        'ubicacion': null,
      }, status: 201),
    );

    final mesa = await datasource.createMesa(
      const MesaRequest(numeroMesa: 8, capacidad: 2, estado: EstadoMesa.libre),
    );

    expect(mesa.id, 8);
    expect(mesa.ubicacion, isNull);
  });

  test('updateMesa PUTs /mesas/{id}', () async {
    when(
      () => dio.put<dynamic>(
        '/mesas/3',
        data: {'numeroMesa': 3, 'capacidad': 6, 'ubicacion': 'Salón'},
      ),
    ).thenAnswer(
      (_) async =>
          okResponse({..._mesaJson, 'capacidad': 6, 'ubicacion': 'Salón'}),
    );

    final mesa = await datasource.updateMesa(
      3,
      const MesaRequest(numeroMesa: 3, capacidad: 6, ubicacion: 'Salón'),
    );

    expect(mesa.capacidad, 6);
    expect(mesa.ubicacion, 'Salón');
  });

  test('deleteMesa DELETEs /mesas/{id} (204)', () async {
    when(() => dio.delete<dynamic>('/mesas/3'))
        .thenAnswer((_) async => okResponse(null, status: 204));

    await datasource.deleteMesa(3);

    verify(() => dio.delete<dynamic>('/mesas/3')).called(1);
  });

  test('updateEstado PATCHes /mesas/{id}/estado with a query param', () async {
    when(
      () => dio.patch<dynamic>(
        '/mesas/3/estado',
        queryParameters: {'estado': 'CUENTA'},
      ),
    ).thenAnswer((_) async => okResponse({..._mesaJson, 'estado': 'CUENTA'}));

    final mesa = await datasource.updateEstado(3, EstadoMesa.cuenta);

    expect(mesa.estado, EstadoMesa.cuenta);
    verify(
      () => dio.patch<dynamic>(
        '/mesas/3/estado',
        queryParameters: {'estado': 'CUENTA'},
      ),
    ).called(1);
  });

  test('lets a DioException propagate', () {
    when(() => dio.get<dynamic>('/mesas/99')).thenThrow(httpError(404));

    expect(datasource.getMesa(99), throwsA(isA<DioException>()));
  });
}
