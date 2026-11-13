import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/models.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/repositories_impl/catalogo_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mock_dio.dart';

class _MockCatalogoDatasource extends Mock implements CatalogoDatasource {}

const _categoriaModel = CategoriaPlatoModel(
  id: 1,
  nombre: 'Entradas',
  areaImpresion: AreaImpresion.cocina,
  ordenVisual: 1,
);

const _platoModel = PlatoModel(
  id: 10,
  idCategoria: 1,
  nombreCategoria: 'Entradas',
  nombre: 'Ceviche',
  descripcion: 'Con limón',
  precioUnitario: 8.5,
  aplicaIva: true,
  disponible: true,
);

const _platoDraft = PlatoDraft(
  idCategoria: 1,
  nombre: 'Ceviche',
  descripcion: 'Con limón',
  precioUnitario: 8.5,
  aplicaIva: true,
  disponible: true,
);

const _platoRequestJson = {
  'idCategoria': 1,
  'nombre': 'Ceviche',
  'descripcion': 'Con limón',
  'precioUnitario': 8.5,
  'aplicaIva': true,
  'disponible': true,
};

PageResult<PlatoModel> _platoPage() => const PageResult<PlatoModel>(
  content: [_platoModel],
  totalElements: 21,
  totalPages: 3,
  number: 1,
  size: 10,
  first: false,
  last: false,
  empty: false,
);

void main() {
  late _MockCatalogoDatasource datasource;
  late CatalogoRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const CategoriaPlatoRequest(
        nombre: '',
        areaImpresion: AreaImpresion.cocina,
      ),
    );
    registerFallbackValue(
      const PlatoRequest(
        idCategoria: 0,
        nombre: '',
        precioUnitario: 0,
        aplicaIva: false,
        disponible: false,
      ),
    );
  });

  setUp(() {
    datasource = _MockCatalogoDatasource();
    repository = CatalogoRepositoryImpl(datasource);
  });

  group('categorias', () {
    test('getCategorias maps models to entities', () async {
      when(() => datasource.getCategorias())
          .thenAnswer((_) async => [_categoriaModel]);

      expect(await repository.getCategorias(), [categoriaFixture()]);
    });

    test('createCategoria maps the draft to the request', () async {
      when(() => datasource.createCategoria(any()))
          .thenAnswer((_) async => _categoriaModel);

      final result = await repository.createCategoria(
        const CategoriaPlatoDraft(
          nombre: 'Entradas',
          areaImpresion: AreaImpresion.cocina,
          ordenVisual: 1,
        ),
      );

      expect(result, categoriaFixture());
      final request =
          verify(() => datasource.createCategoria(captureAny())).captured.single
              as CategoriaPlatoRequest;
      expect(request.toJson(), {
        'nombre': 'Entradas',
        'areaImpresion': 'COCINA',
        'ordenVisual': 1,
      });
    });

    test('updateCategoria passes the id and the request', () async {
      when(() => datasource.updateCategoria(any(), any()))
          .thenAnswer((_) async => _categoriaModel);

      await repository.updateCategoria(
        1,
        const CategoriaPlatoDraft(
          nombre: 'Bebidas',
          areaImpresion: AreaImpresion.bar,
        ),
      );

      final captured = verify(
        () => datasource.updateCategoria(captureAny(), captureAny()),
      ).captured;
      expect(captured.first, 1);
      expect((captured.last as CategoriaPlatoRequest).toJson(), {
        'nombre': 'Bebidas',
        'areaImpresion': 'BAR',
      });
    });

    test('deleteCategoria maps a 404 to NotFoundException', () async {
      when(() => datasource.deleteCategoria(7))
          .thenThrow(httpError(404, {'message': 'Categoría no encontrada'}));

      await expectLater(
        repository.deleteCategoria(7),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'Categoría no encontrada',
          ),
        ),
      );
    });

    test('deleteCategoria delegates to the datasource', () async {
      when(() => datasource.deleteCategoria(1)).thenAnswer((_) async {});

      await repository.deleteCategoria(1);

      verify(() => datasource.deleteCategoria(1)).called(1);
    });
  });

  group('platos', () {
    test('getPlatos keeps the paging metadata', () async {
      when(() => datasource.getPlatos(page: 1, size: 10))
          .thenAnswer((_) async => _platoPage());

      final page = await repository.getPlatos(page: 1, size: 10);

      expect(page.content, [platoFixture()]);
      expect(page.totalElements, 21);
      expect(page.totalPages, 3);
      expect(page.number, 1);
      expect(page.hasNext, isTrue);
    });

    test('getPlatos forwards the default paging', () async {
      when(() => datasource.getPlatos(page: 0, size: 100))
          .thenAnswer((_) async => PageResult<PlatoModel>.single(const []));

      final page = await repository.getPlatos();

      expect(page.empty, isTrue);
    });

    test('getPlatosByCategoria forwards id and paging', () async {
      when(() => datasource.getPlatosByCategoria(1, page: 2, size: 5))
          .thenAnswer((_) async => _platoPage());

      final page = await repository.getPlatosByCategoria(1, page: 2, size: 5);

      expect(page.content.single, platoFixture());
    });

    test('searchPlatos forwards the filters', () async {
      when(
        () => datasource.searchPlatos(
          nombre: 'cev',
          idCategoria: null,
          disponible: true,
          size: 50,
        ),
      ).thenAnswer((_) async => _platoPage());

      final page = await repository.searchPlatos(
        nombre: 'cev',
        disponible: true,
      );

      expect(page.content.single.nombre, 'Ceviche');
    });

    test('getPlato maps the model', () async {
      when(() => datasource.getPlato(10)).thenAnswer((_) async => _platoModel);

      expect(await repository.getPlato(10), platoFixture());
    });

    test('getPlato maps a 404 to NotFoundException', () async {
      when(() => datasource.getPlato(99)).thenThrow(httpError(404));

      await expectLater(
        repository.getPlato(99),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('createPlato maps the draft to the request', () async {
      when(() => datasource.createPlato(any()))
          .thenAnswer((_) async => _platoModel);

      expect(await repository.createPlato(_platoDraft), platoFixture());
      final request =
          verify(() => datasource.createPlato(captureAny())).captured.single
              as PlatoRequest;
      expect(request.toJson(), _platoRequestJson);
    });

    test('updatePlato passes the id and the request', () async {
      when(() => datasource.updatePlato(any(), any()))
          .thenAnswer((_) async => _platoModel);

      await repository.updatePlato(10, _platoDraft);

      final captured = verify(
        () => datasource.updatePlato(captureAny(), captureAny()),
      ).captured;
      expect(captured.first, 10);
      expect((captured.last as PlatoRequest).toJson(), _platoRequestJson);
    });

    test('deletePlato maps network failures', () async {
      when(() => datasource.deletePlato(10)).thenThrow(connectionFailure());

      await expectLater(
        repository.deletePlato(10),
        throwsA(isA<NetworkException>()),
      );
    });

    test('a 403 becomes ForbiddenException', () async {
      when(() => datasource.createPlato(any())).thenThrow(httpError(403));

      await expectLater(
        repository.createPlato(_platoDraft),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });
}
