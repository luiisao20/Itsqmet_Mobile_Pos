import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:mocktail/mocktail.dart';

class _MockInsumos extends Mock implements InsumoRepository {}

Insumo _insumo(int id) => Insumo(
  id: id,
  nombre: 'Tomate $id',
  unidadMedida: UnidadMedida.kg,
  stockActual: 2.5,
  stockMinimo: 3,
  costoPromedio: 0.85,
  stockBajo: true,
);

const _draft = InsumoDraft(
  nombre: '  Aceite  ',
  unidadMedida: UnidadMedida.lt,
  stockActual: 12,
  stockMinimo: 4,
  costoPromedio: 3.2,
);

void main() {
  late _MockInsumos insumos;
  late AdminChanges changes;

  InsumosCubit build() =>
      InsumosCubit(insumoRepository: insumos, changes: changes);

  setUpAll(() => registerFallbackValue(_draft));

  setUp(() {
    insumos = _MockInsumos();
    changes = AdminChanges();
    when(() => insumos.getInsumos(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single([_insumo(1), _insumo(2)]));
  });

  test('loads 100 insumos', () async {
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items.map((i) => i.id), [1, 2]);
    verify(() => insumos.getInsumos(page: 0, size: 100)).called(1);
    await cubit.close();
  });

  test('a load error keeps an empty list', () async {
    when(() => insumos.getInsumos(page: 0, size: 100))
        .thenThrow(const ServerException());
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items, isEmpty);
    expect(cubit.state.loading, isFalse);
    await cubit.close();
  });

  group('draftFor', () {
    test('a new insumo uses UNIDAD, stock 10, minimo 5 and costo 1', () async {
      final cubit = build();

      expect(
        cubit.draftFor(null),
        const InsumoDraft(
          nombre: '',
          unidadMedida: UnidadMedida.unidad,
          stockActual: 10,
          stockMinimo: 5,
          costoPromedio: 1.0,
        ),
      );
      await cubit.close();
    });

    test('an existing insumo copies its values', () async {
      final cubit = build();

      expect(
        cubit.draftFor(_insumo(4)),
        const InsumoDraft(
          nombre: 'Tomate 4',
          unidadMedida: UnidadMedida.kg,
          stockActual: 2.5,
          stockMinimo: 3,
          costoPromedio: 0.85,
        ),
      );
      await cubit.close();
    });
  });

  group('saveInsumo', () {
    test('creates a trimmed insumo, notifies and reloads', () async {
      when(() => insumos.createInsumo(any()))
          .thenAnswer((_) async => _insumo(9));
      var notified = 0;
      final subscription = changes.stream.listen((_) => notified++);
      final cubit = build();

      final ok = await cubit.saveInsumo(_draft);
      await pumpEventQueue();

      expect(ok, isTrue);
      verify(
        () => insumos.createInsumo(
          const InsumoDraft(
            nombre: 'Aceite',
            unidadMedida: UnidadMedida.lt,
            stockActual: 12,
            stockMinimo: 4,
            costoPromedio: 3.2,
          ),
        ),
      ).called(1);
      verify(() => insumos.getInsumos(page: 0, size: 100)).called(1);
      expect(notified, 1);
      await subscription.cancel();
      await cubit.close();
    });

    test('an id updates that insumo', () async {
      when(() => insumos.updateInsumo(any(), any()))
          .thenAnswer((_) async => _insumo(4));
      final cubit = build();

      await cubit.saveInsumo(_draft, id: 4);

      verify(() => insumos.updateInsumo(4, any())).called(1);
      verifyNever(() => insumos.createInsumo(any()));
      await cubit.close();
    });

    test('zero stock values are valid', () async {
      when(() => insumos.createInsumo(any()))
          .thenAnswer((_) async => _insumo(9));
      final cubit = build();

      final ok = await cubit.saveInsumo(
        const InsumoDraft(
          nombre: 'Sal',
          unidadMedida: UnidadMedida.kg,
          stockActual: 0,
          stockMinimo: 0,
          costoPromedio: 0,
        ),
      );

      expect(ok, isTrue);
      await cubit.close();
    });

    test('rejects an empty name or a negative stock', () async {
      final cubit = build();
      const message = 'Ingresa un nombre y cantidades válidas';

      final emptyName = await cubit.saveInsumo(
        const InsumoDraft(
          nombre: '   ',
          unidadMedida: UnidadMedida.kg,
          stockActual: 1,
          stockMinimo: 1,
          costoPromedio: 1,
        ),
      );
      expect(emptyName, isFalse);
      expect(cubit.state.error!.message, message);
      final firstError = cubit.state.error;

      final negativeStock = await cubit.saveInsumo(
        const InsumoDraft(
          nombre: 'Sal',
          unidadMedida: UnidadMedida.kg,
          stockActual: -1,
          stockMinimo: 1,
          costoPromedio: 1,
        ),
      );
      expect(negativeStock, isFalse);
      expect(cubit.state.error!.message, message);
      expect(cubit.state.error, isNot(firstError));

      final negativeMinimo = await cubit.saveInsumo(
        const InsumoDraft(
          nombre: 'Sal',
          unidadMedida: UnidadMedida.kg,
          stockActual: 1,
          stockMinimo: -0.5,
          costoPromedio: 1,
        ),
      );
      expect(negativeMinimo, isFalse);
      expect(cubit.state.error!.message, message);
      verifyNever(() => insumos.createInsumo(any()));
      await cubit.close();
    });

    test('a backend message is shown', () async {
      when(() => insumos.createInsumo(any()))
          .thenThrow(const BadRequestException('Insumo duplicado'));
      final cubit = build();

      final ok = await cubit.saveInsumo(_draft);

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Insumo duplicado');
      expect(cubit.state.submitting, isFalse);
      await cubit.close();
    });

    test('a backend error without message uses the fallback', () async {
      when(() => insumos.createInsumo(any()))
          .thenThrow(const BadRequestException(''));
      final cubit = build();

      await cubit.saveInsumo(_draft);

      expect(cubit.state.error!.message, 'Error al guardar insumo');
      await cubit.close();
    });
  });

  group('deleteInsumo', () {
    test('deletes and reloads', () async {
      when(() => insumos.deleteInsumo(any())).thenAnswer((_) async {});
      final cubit = build();

      final ok = await cubit.deleteInsumo(_insumo(2));

      expect(ok, isTrue);
      verify(() => insumos.deleteInsumo(2)).called(1);
      verify(() => insumos.getInsumos(page: 0, size: 100)).called(1);
      await cubit.close();
    });

    test('an error uses the delete fallback', () async {
      when(() => insumos.deleteInsumo(any()))
          .thenThrow(const ServerException(''));
      final cubit = build();

      await cubit.deleteInsumo(_insumo(2));

      expect(cubit.state.error!.message, 'Error al eliminar insumo');
      await cubit.close();
    });
  });
}
