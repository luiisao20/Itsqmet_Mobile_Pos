import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogo extends Mock implements CatalogoRepository {}

CategoriaPlato _categoria(
  int id, {
  AreaImpresion area = AreaImpresion.cocina,
  int? orden,
}) => CategoriaPlato(
  id: id,
  nombre: 'Categoria $id',
  areaImpresion: area,
  ordenVisual: orden,
);

const _draft = CategoriaPlatoDraft(
  nombre: '  Bebidas  ',
  areaImpresion: AreaImpresion.bar,
  ordenVisual: 4,
);

void main() {
  late _MockCatalogo catalogo;
  late AdminChanges changes;

  CategoriasCubit build() =>
      CategoriasCubit(catalogoRepository: catalogo, changes: changes);

  setUpAll(() => registerFallbackValue(_draft));

  setUp(() {
    catalogo = _MockCatalogo();
    changes = AdminChanges();
    when(() => catalogo.getCategorias()).thenAnswer(
      (_) async => [_categoria(1, orden: 1), _categoria(2, orden: 2)],
    );
  });

  test('loads the categorias', () async {
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items.map((c) => c.id), [1, 2]);
    expect(cubit.state.loading, isFalse);
    await cubit.close();
  });

  test('a load error keeps the current categorias', () async {
    when(() => catalogo.getCategorias()).thenThrow(const ServerException());
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items, isEmpty);
    expect(cubit.state.loading, isFalse);
    await cubit.close();
  });

  group('draftFor', () {
    test('a new categoria prints in COCINA after the loaded ones', () async {
      final cubit = build();
      await cubit.load();

      expect(
        cubit.draftFor(null),
        const CategoriaPlatoDraft(
          nombre: '',
          areaImpresion: AreaImpresion.cocina,
          ordenVisual: 3,
        ),
      );
      await cubit.close();
    });

    test('without categorias a new categoria uses orden 1', () async {
      final cubit = build();

      expect(cubit.draftFor(null).ordenVisual, 1);
      await cubit.close();
    });

    test('an existing categoria copies its values', () async {
      final cubit = build();

      expect(
        cubit.draftFor(_categoria(5, area: AreaImpresion.bar, orden: 7)),
        const CategoriaPlatoDraft(
          nombre: 'Categoria 5',
          areaImpresion: AreaImpresion.bar,
          ordenVisual: 7,
        ),
      );
      await cubit.close();
    });

    test('an existing categoria without orden uses 1', () async {
      final cubit = build();

      expect(cubit.draftFor(_categoria(5)).ordenVisual, 1);
      expect(cubit.draftFor(_categoria(5, orden: 0)).ordenVisual, 1);
      await cubit.close();
    });
  });

  group('saveCategoria', () {
    test('creates a trimmed categoria, notifies and reloads', () async {
      when(() => catalogo.createCategoria(any()))
          .thenAnswer((_) async => _categoria(9));
      var notified = 0;
      final subscription = changes.stream.listen((_) => notified++);
      final cubit = build();

      final ok = await cubit.saveCategoria(_draft);
      await Future<void>.delayed(Duration.zero);

      expect(ok, isTrue);
      verify(
        () => catalogo.createCategoria(
          const CategoriaPlatoDraft(
            nombre: 'Bebidas',
            areaImpresion: AreaImpresion.bar,
            ordenVisual: 4,
          ),
        ),
      ).called(1);
      verify(() => catalogo.getCategorias()).called(1);
      expect(notified, 1);
      expect(cubit.state.submitting, isFalse);
      await subscription.cancel();
      await cubit.close();
    });

    test('an id updates that categoria', () async {
      when(() => catalogo.updateCategoria(any(), any()))
          .thenAnswer((_) async => _categoria(4));
      final cubit = build();

      final ok = await cubit.saveCategoria(_draft, id: 4);

      expect(ok, isTrue);
      verify(() => catalogo.updateCategoria(4, any())).called(1);
      verifyNever(() => catalogo.createCategoria(any()));
      await cubit.close();
    });

    test('rejects an empty name', () async {
      final cubit = build();

      final ok = await cubit.saveCategoria(
        const CategoriaPlatoDraft(
          nombre: '   ',
          areaImpresion: AreaImpresion.cocina,
          ordenVisual: 1,
        ),
      );

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Ingresa el nombre de la categoría');
      verifyNever(() => catalogo.createCategoria(any()));
      await cubit.close();
    });

    test('a backend message is shown as is', () async {
      when(() => catalogo.createCategoria(any()))
          .thenThrow(const BadRequestException('Nombre duplicado'));
      final cubit = build();

      final ok = await cubit.saveCategoria(_draft);

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Nombre duplicado');
      await cubit.close();
    });

    test('a backend error without message uses the fallback', () async {
      when(() => catalogo.createCategoria(any()))
          .thenThrow(const BadRequestException(''));
      final cubit = build();

      await cubit.saveCategoria(_draft);

      expect(cubit.state.error!.message, 'Error al guardar categoría');
      await cubit.close();
    });
  });

  group('deleteCategoria', () {
    test('deletes and reloads', () async {
      when(() => catalogo.deleteCategoria(any())).thenAnswer((_) async {});
      final cubit = build();

      final ok = await cubit.deleteCategoria(_categoria(2));

      expect(ok, isTrue);
      verify(() => catalogo.deleteCategoria(2)).called(1);
      verify(() => catalogo.getCategorias()).called(1);
      await cubit.close();
    });

    test('an error uses the delete fallback', () async {
      when(() => catalogo.deleteCategoria(any()))
          .thenThrow(const ServerException(''));
      final cubit = build();

      final ok = await cubit.deleteCategoria(_categoria(2));

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Error al eliminar categoría');
      await cubit.close();
    });
  });
}
