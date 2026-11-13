import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:mocktail/mocktail.dart';

class _MockMesas extends Mock implements MesaRepository {}

Mesa _mesa(
  int id, {
  int numero = 1,
  String? ubicacion = 'Terraza',
  EstadoMesa estado = EstadoMesa.ocupada,
}) => Mesa(
  id: id,
  numeroMesa: numero,
  capacidad: 6,
  ubicacion: ubicacion,
  estado: estado,
);

const _draft = MesaDraft(
  numeroMesa: 12,
  capacidad: 4,
  ubicacion: '  Terraza  ',
  estado: EstadoMesa.cuenta,
);

void main() {
  late _MockMesas mesas;
  late AdminChanges changes;

  AdminMesasCubit build() =>
      AdminMesasCubit(mesaRepository: mesas, changes: changes);

  setUpAll(() => registerFallbackValue(_draft));

  setUp(() {
    mesas = _MockMesas();
    changes = AdminChanges();
    when(() => mesas.getMesas(page: 0, size: 100)).thenAnswer(
      (_) async =>
          PageResult.single([_mesa(1, numero: 3), _mesa(2, numero: 8)]),
    );
  });

  test('loads 100 mesas', () async {
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items.map((m) => m.id), [1, 2]);
    verify(() => mesas.getMesas(page: 0, size: 100)).called(1);
    await cubit.close();
  });

  group('draftFor', () {
    test('a new mesa uses the next number, 4 seats, Salón Principal and '
        'LIBRE', () async {
      final cubit = build();
      await cubit.load();

      expect(
        cubit.draftFor(null),
        const MesaDraft(
          numeroMesa: 9,
          capacidad: 4,
          ubicacion: 'Salón Principal',
          estado: EstadoMesa.libre,
        ),
      );
      await cubit.close();
    });

    test('without mesas a new mesa is number 1', () async {
      final cubit = build();

      expect(cubit.draftFor(null).numeroMesa, 1);
      await cubit.close();
    });

    test('an existing mesa copies its values', () async {
      final cubit = build();

      expect(
        cubit.draftFor(_mesa(4, numero: 5)),
        const MesaDraft(
          numeroMesa: 5,
          capacidad: 6,
          ubicacion: 'Terraza',
          estado: EstadoMesa.ocupada,
        ),
      );
      await cubit.close();
    });

    test('an existing mesa without ubicacion uses Salón Principal', () async {
      final cubit = build();

      expect(
        cubit.draftFor(_mesa(4, ubicacion: null)).ubicacion,
        'Salón Principal',
      );
      await cubit.close();
    });
  });

  group('saveMesa', () {
    test('creates a mesa with a trimmed ubicacion', () async {
      when(() => mesas.createMesa(any())).thenAnswer((_) async => _mesa(9));
      final cubit = build();

      final ok = await cubit.saveMesa(_draft);

      expect(ok, isTrue);
      verify(
        () => mesas.createMesa(
          const MesaDraft(
            numeroMesa: 12,
            capacidad: 4,
            ubicacion: 'Terraza',
            estado: EstadoMesa.cuenta,
          ),
        ),
      ).called(1);
      await cubit.close();
    });

    test('a blank ubicacion is omitted', () async {
      when(() => mesas.createMesa(any())).thenAnswer((_) async => _mesa(9));
      final cubit = build();

      await cubit.saveMesa(
        const MesaDraft(
          numeroMesa: 2,
          capacidad: 2,
          ubicacion: '   ',
          estado: EstadoMesa.libre,
        ),
      );

      final draft =
          verify(() => mesas.createMesa(captureAny())).captured.single
              as MesaDraft;
      expect(draft.ubicacion, isNull);
      await cubit.close();
    });

    test('an id updates that mesa', () async {
      when(() => mesas.updateMesa(any(), any()))
          .thenAnswer((_) async => _mesa(4));
      final cubit = build();

      await cubit.saveMesa(_draft, id: 4);

      verify(() => mesas.updateMesa(4, any())).called(1);
      verifyNever(() => mesas.createMesa(any()));
      await cubit.close();
    });

    test('rejects a number or capacity not above zero', () async {
      final cubit = build();

      final zeroNumber = await cubit.saveMesa(
        const MesaDraft(numeroMesa: 0, capacidad: 4),
      );
      expect(zeroNumber, isFalse);
      expect(
        cubit.state.error!.message,
        'Número de mesa y capacidad deben ser mayores a 0',
      );

      final zeroCapacity = await cubit.saveMesa(
        const MesaDraft(numeroMesa: 3, capacidad: 0),
      );
      expect(zeroCapacity, isFalse);
      verifyNever(() => mesas.createMesa(any()));
      await cubit.close();
    });

    test('a backend error without message uses the fallback', () async {
      when(() => mesas.createMesa(any()))
          .thenThrow(const BadRequestException(''));
      final cubit = build();

      await cubit.saveMesa(_draft);

      expect(cubit.state.error!.message, 'Error al guardar mesa');
      await cubit.close();
    });

    test('a backend message is kept', () async {
      when(() => mesas.createMesa(any()))
          .thenThrow(const BadRequestException('La mesa ya existe'));
      final cubit = build();

      await cubit.saveMesa(_draft);

      expect(cubit.state.error!.message, 'La mesa ya existe');
      await cubit.close();
    });
  });

  group('deleteMesa', () {
    test('deletes and reloads', () async {
      when(() => mesas.deleteMesa(any())).thenAnswer((_) async {});
      final cubit = build();

      final ok = await cubit.deleteMesa(_mesa(2));

      expect(ok, isTrue);
      verify(() => mesas.deleteMesa(2)).called(1);
      verify(() => mesas.getMesas(page: 0, size: 100)).called(1);
      await cubit.close();
    });

    test('an error uses the delete fallback', () async {
      when(() => mesas.deleteMesa(any())).thenThrow(const ServerException(''));
      final cubit = build();

      await cubit.deleteMesa(_mesa(2));

      expect(cubit.state.error!.message, 'Error al eliminar mesa');
      await cubit.close();
    });
  });
}
