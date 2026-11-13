import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/datasources/api_catalogo_datasource.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_dio.dart';

const _categoriaJson = {
  'id': 1,
  'nombre': 'Entradas',
  'areaImpresion': 'COCINA',
  'ordenVisual': 1,
  'createdAt': '2025-01-10T12:00:00',
};

const _platoJson = {
  'id': 10,
  'idCategoria': 1,
  'nombreCategoria': 'Entradas',
  'nombre': 'Ceviche',
  'descripcion': 'Con limón',
  'precioUnitario': 8.5,
  'aplicaIva': true,
  'disponible': true,
};

void main() {
  late MockDio dio;
  late ApiCatalogoDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = ApiCatalogoDatasource(dio);
  });

  group('categorias', () {
    test('getCategorias GETs /categorias-plato and unwraps the page', () async {
      when(
        () => dio.get<dynamic>(
          '/categorias-plato',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).thenAnswer((_) async => okResponse(pageJson([_categoriaJson])));

      final result = await datasource.getCategorias();

      expect(result, hasLength(1));
      expect(result.single.id, 1);
      expect(result.single.nombre, 'Entradas');
      expect(result.single.areaImpresion, AreaImpresion.cocina);
      expect(result.single.ordenVisual, 1);
    });

    test('getCategorias accepts a plain array', () async {
      when(
        () => dio.get<dynamic>(
          '/categorias-plato',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => okResponse([
          _categoriaJson,
          {..._categoriaJson, 'id': 2, 'areaImpresion': 'BAR'},
        ]),
      );

      final result = await datasource.getCategorias();

      expect(result.map((c) => c.id), [1, 2]);
      expect(result.last.areaImpresion, AreaImpresion.bar);
    });

    test('createCategoria POSTs the request body', () async {
      const request = CategoriaPlatoRequest(
        nombre: 'Bebidas',
        areaImpresion: AreaImpresion.bar,
        ordenVisual: 2,
      );
      when(
        () => dio.post<dynamic>(
          '/categorias-plato',
          data: {'nombre': 'Bebidas', 'areaImpresion': 'BAR', 'ordenVisual': 2},
        ),
      ).thenAnswer(
        (_) async => okResponse({
          ..._categoriaJson,
          'id': 5,
          'nombre': 'Bebidas',
          'areaImpresion': 'BAR',
        }, status: 201),
      );

      final result = await datasource.createCategoria(request);

      expect(result.id, 5);
      expect(result.nombre, 'Bebidas');
    });

    test('updateCategoria PUTs /categorias-plato/{id}', () async {
      when(
        () => dio.put<dynamic>(
          '/categorias-plato/1',
          data: {'nombre': 'Entradas frías', 'areaImpresion': 'COCINA'},
        ),
      ).thenAnswer(
        (_) async =>
            okResponse({..._categoriaJson, 'nombre': 'Entradas frías'}),
      );

      final result = await datasource.updateCategoria(
        1,
        const CategoriaPlatoRequest(
          nombre: 'Entradas frías',
          areaImpresion: AreaImpresion.cocina,
        ),
      );

      expect(result.nombre, 'Entradas frías');
    });

    test('deleteCategoria DELETEs /categorias-plato/{id} (204)', () async {
      when(() => dio.delete<dynamic>('/categorias-plato/1'))
          .thenAnswer((_) async => okResponse(null, status: 204));

      await datasource.deleteCategoria(1);

      verify(() => dio.delete<dynamic>('/categorias-plato/1')).called(1);
    });

    test('lets a DioException propagate (mapping is the repository job)', () {
      when(() => dio.delete<dynamic>('/categorias-plato/1'))
          .thenThrow(httpError(404, {'message': 'No existe'}));

      expect(datasource.deleteCategoria(1), throwsA(isA<DioException>()));
    });
  });

  group('platos', () {
    test('getPlatos GETs /platos with page and size', () async {
      when(
        () => dio.get<dynamic>(
          '/platos',
          queryParameters: {'page': 2, 'size': 20},
        ),
      ).thenAnswer(
        (_) async => okResponse({
          ...pageJson([_platoJson]),
          'number': 2,
          'totalElements': 41,
          'totalPages': 3,
          'first': false,
          'last': true,
        }),
      );

      final page = await datasource.getPlatos(page: 2, size: 20);

      expect(page.number, 2);
      expect(page.totalElements, 41);
      expect(page.totalPages, 3);
      expect(page.content.single.nombre, 'Ceviche');
      expect(page.content.single.precioUnitario, 8.5);
      expect(page.content.single.aplicaIva, isTrue);
    });

    test('getPlatos uses page 0 and size 100 by default', () async {
      when(
        () => dio.get<dynamic>(
          '/platos',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).thenAnswer((_) async => okResponse(pageJson(const [])));

      final page = await datasource.getPlatos();

      expect(page.empty, isTrue);
      expect(page.content, isEmpty);
    });

    test('getPlatosByCategoria GETs /platos/categoria/{id}', () async {
      when(
        () => dio.get<dynamic>(
          '/platos/categoria/1',
          queryParameters: {'page': 0, 'size': 100},
        ),
      ).thenAnswer((_) async => okResponse(pageJson([_platoJson])));

      final page = await datasource.getPlatosByCategoria(1);

      expect(page.content.single.idCategoria, 1);
    });

    test('searchPlatos sends only the non-null filters', () async {
      when(
        () => dio.get<dynamic>(
          '/platos/buscar',
          queryParameters: {'size': 50, 'nombre': 'cev', 'disponible': true},
        ),
      ).thenAnswer((_) async => okResponse(pageJson([_platoJson])));

      final page = await datasource.searchPlatos(
        nombre: 'cev',
        disponible: true,
      );

      expect(page.content.single.id, 10);
    });

    test('searchPlatos sends idCategoria when given', () async {
      when(
        () => dio.get<dynamic>(
          '/platos/buscar',
          queryParameters: {'size': 10, 'idCategoria': 3},
        ),
      ).thenAnswer((_) async => okResponse(pageJson(const [])));

      final page = await datasource.searchPlatos(idCategoria: 3, size: 10);

      expect(page.content, isEmpty);
    });

    test('getPlato GETs /platos/{id}', () async {
      when(() => dio.get<dynamic>('/platos/10'))
          .thenAnswer((_) async => okResponse(_platoJson));

      final plato = await datasource.getPlato(10);

      expect(plato.id, 10);
      expect(plato.nombreCategoria, 'Entradas');
    });

    test('createPlato POSTs /platos with the request body', () async {
      const request = PlatoRequest(
        idCategoria: 1,
        nombre: 'Ceviche',
        precioUnitario: 8.5,
        aplicaIva: true,
        disponible: true,
      );
      when(
        () => dio.post<dynamic>(
          '/platos',
          data: {
            'idCategoria': 1,
            'nombre': 'Ceviche',
            'precioUnitario': 8.5,
            'aplicaIva': true,
            'disponible': true,
          },
        ),
      ).thenAnswer((_) async => okResponse(_platoJson, status: 201));

      final plato = await datasource.createPlato(request);

      expect(plato.id, 10);
    });

    test('updatePlato PUTs /platos/{id}', () async {
      const request = PlatoRequest(
        idCategoria: 1,
        nombre: 'Ceviche mixto',
        descripcion: 'Camarón',
        precioUnitario: 10,
        aplicaIva: false,
        disponible: false,
        urlImagen: 'http://img/1.png',
      );
      when(() => dio.put<dynamic>('/platos/10', data: request.toJson()))
          .thenAnswer(
            (_) async => okResponse({
              ..._platoJson,
              'nombre': 'Ceviche mixto',
              'disponible': false,
            }),
          );

      final plato = await datasource.updatePlato(10, request);

      expect(plato.nombre, 'Ceviche mixto');
      expect(plato.disponible, isFalse);
    });

    test('deletePlato DELETEs /platos/{id}', () async {
      when(() => dio.delete<dynamic>('/platos/10'))
          .thenAnswer((_) async => okResponse(null, status: 204));

      await datasource.deletePlato(10);

      verify(() => dio.delete<dynamic>('/platos/10')).called(1);
    });
  });
}
