import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogo extends Mock implements CatalogoRepository {}

Plato _plato(int id, {bool disponible = true}) => Plato(
  id: id,
  idCategoria: 3,
  nombre: 'Seco $id',
  descripcion: 'Con arroz',
  precioUnitario: 8.5,
  aplicaIva: true,
  disponible: disponible,
  urlImagen: 'https://img/$id.png',
);

const _bebidas = CategoriaPlato(
  id: 7,
  nombre: 'Bebidas',
  areaImpresion: AreaImpresion.bar,
);

const _draft = PlatoDraft(
  idCategoria: 7,
  nombre: '  Seco de Chivo  ',
  descripcion: '  Con maduro  ',
  precioUnitario: 9.75,
  aplicaIva: false,
  disponible: true,
  urlImagen: '   ',
);

void main() {
  late _MockCatalogo catalogo;
  late AdminChanges changes;

  PlatosCubit build() =>
      PlatosCubit(catalogoRepository: catalogo, changes: changes);

  setUpAll(() => registerFallbackValue(_draft));

  setUp(() {
    catalogo = _MockCatalogo();
    changes = AdminChanges();
    when(() => catalogo.getPlatos(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single([_plato(1), _plato(2)]));
    when(() => catalogo.getCategorias()).thenAnswer((_) async => [_bebidas]);
  });

  test('loads 100 platos and the categorias for the form', () async {
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items.map((p) => p.id), [1, 2]);
    expect(cubit.categorias, [_bebidas]);
    await cubit.close();
  });

  test('a categorias error keeps the platos', () async {
    when(() => catalogo.getCategorias()).thenThrow(const ServerException());
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items, hasLength(2));
    expect(cubit.categorias, isEmpty);
    await cubit.close();
  });

  group('draftFor', () {
    test('a new plato uses the first categoria, zero price, IVA and '
        'available', () async {
      final cubit = build();
      await cubit.load();

      expect(
        cubit.draftFor(null),
        const PlatoDraft(
          idCategoria: 7,
          nombre: '',
          descripcion: '',
          precioUnitario: 0,
          aplicaIva: true,
          disponible: true,
          urlImagen: '',
        ),
      );
      await cubit.close();
    });

    test('without categorias a new plato uses categoria 1', () async {
      final cubit = build();

      expect(cubit.draftFor(null).idCategoria, 1);
      await cubit.close();
    });

    test('an existing plato copies its values', () async {
      final cubit = build();

      expect(
        cubit.draftFor(_plato(4)),
        const PlatoDraft(
          idCategoria: 3,
          nombre: 'Seco 4',
          descripcion: 'Con arroz',
          precioUnitario: 8.5,
          aplicaIva: true,
          disponible: true,
          urlImagen: 'https://img/4.png',
        ),
      );
      await cubit.close();
    });
  });

  group('savePlato', () {
    test('creates a trimmed plato and omits blank optional text', () async {
      when(() => catalogo.createPlato(any()))
          .thenAnswer((_) async => _plato(9));
      final cubit = build();

      final ok = await cubit.savePlato(_draft);

      expect(ok, isTrue);
      verify(
        () => catalogo.createPlato(
          const PlatoDraft(
            idCategoria: 7,
            nombre: 'Seco de Chivo',
            descripcion: 'Con maduro',
            precioUnitario: 9.75,
            aplicaIva: false,
            disponible: true,
          ),
        ),
      ).called(1);
      await cubit.close();
    });

    test('an id updates that plato', () async {
      when(() => catalogo.updatePlato(any(), any()))
          .thenAnswer((_) async => _plato(4));
      final cubit = build();

      await cubit.savePlato(_draft, id: 4);

      verify(() => catalogo.updatePlato(4, any())).called(1);
      verifyNever(() => catalogo.createPlato(any()));
      await cubit.close();
    });

    test('rejects an empty name or a price not above zero', () async {
      final cubit = build();

      final emptyName = await cubit.savePlato(
        const PlatoDraft(
          idCategoria: 1,
          nombre: '   ',
          precioUnitario: 5,
          aplicaIva: true,
          disponible: true,
        ),
      );
      expect(emptyName, isFalse);
      expect(cubit.state.error!.message, 'Ingresa un nombre y precio válido');

      final zeroPrice = await cubit.savePlato(
        const PlatoDraft(
          idCategoria: 1,
          nombre: 'Seco',
          precioUnitario: 0,
          aplicaIva: true,
          disponible: true,
        ),
      );
      expect(zeroPrice, isFalse);
      verifyNever(() => catalogo.createPlato(any()));
      await cubit.close();
    });

    test('a backend error without message uses the fallback', () async {
      when(() => catalogo.createPlato(any()))
          .thenThrow(const BadRequestException(''));
      final cubit = build();

      await cubit.savePlato(_draft);

      expect(cubit.state.error!.message, 'Error al procesar el plato');
      await cubit.close();
    });
  });

  group('toggleDisponible', () {
    test('updates the plato with the opposite availability', () async {
      when(() => catalogo.updatePlato(any(), any()))
          .thenAnswer((_) async => _plato(1, disponible: false));
      final cubit = build();

      final ok = await cubit.toggleDisponible(_plato(1));

      expect(ok, isTrue);
      final draft =
          verify(() => catalogo.updatePlato(1, captureAny())).captured.single
              as PlatoDraft;
      expect(draft.disponible, isFalse);
      expect(draft.nombre, 'Seco 1');
      expect(draft.precioUnitario, 8.5);
      await cubit.close();
    });

    test('an error uses the availability fallback', () async {
      when(() => catalogo.updatePlato(any(), any()))
          .thenThrow(const ServerException(' '));
      final cubit = build();

      await cubit.toggleDisponible(_plato(1));

      expect(cubit.state.error!.message, 'Error al actualizar disponibilidad');
      await cubit.close();
    });
  });

  group('deletePlato', () {
    test('deletes and reloads', () async {
      when(() => catalogo.deletePlato(any())).thenAnswer((_) async {});
      final cubit = build();

      final ok = await cubit.deletePlato(_plato(2));

      expect(ok, isTrue);
      verify(() => catalogo.deletePlato(2)).called(1);
      verify(() => catalogo.getPlatos(page: 0, size: 100)).called(1);
      await cubit.close();
    });

    test('an error uses the delete fallback', () async {
      when(() => catalogo.deletePlato(any()))
          .thenThrow(const ServerException(''));
      final cubit = build();

      await cubit.deletePlato(_plato(2));

      expect(cubit.state.error!.message, 'Error al eliminar plato');
      await cubit.close();
    });
  });
}
