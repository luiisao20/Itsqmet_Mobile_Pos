import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/distribuidores_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockDistribuidores extends Mock implements DistribuidorRepository {}

Distribuidor _distribuidor(int id) => Distribuidor(
  id: id,
  ruc: '179000000$id',
  razonSocial: 'Pronaca $id',
  nombreContacto: 'Ana',
  telefono: '0991234567',
  email: 'ventas@pronaca.ec',
  direccion: 'Quito',
  categoriaProveedor: 'Carnes',
);

const _draft = DistribuidorDraft(
  ruc: '  1790000001001  ',
  razonSocial: '  Pronaca Cía. Ltda.  ',
  nombreContacto: '  Ana Pérez  ',
  telefono: '   ',
  email: '  ventas@pronaca.ec  ',
  direccion: '',
  categoriaProveedor: '  Carnes  ',
);

void main() {
  late _MockDistribuidores repository;
  late AdminChanges changes;

  DistribuidoresCubit build() =>
      DistribuidoresCubit(distribuidorRepository: repository, changes: changes);

  setUpAll(() => registerFallbackValue(_draft));

  setUp(() {
    repository = _MockDistribuidores();
    changes = AdminChanges();
    when(() => repository.getDistribuidores(page: 0, size: 100)).thenAnswer(
      (_) async => PageResult.single([_distribuidor(1), _distribuidor(2)]),
    );
  });

  test('loads the first 100 distribuidores', () async {
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items.map((d) => d.id), [1, 2]);
    verify(() => repository.getDistribuidores(page: 0, size: 100)).called(1);
    await cubit.close();
  });

  group('draftFor', () {
    test('a new distribuidor is empty with categoria Alimentos', () async {
      final cubit = build();

      expect(
        cubit.draftFor(null),
        const DistribuidorDraft(
          ruc: '',
          razonSocial: '',
          nombreContacto: '',
          telefono: '',
          email: '',
          direccion: '',
          categoriaProveedor: 'Alimentos',
        ),
      );
      await cubit.close();
    });

    test('an existing distribuidor copies its values', () async {
      final cubit = build();

      expect(
        cubit.draftFor(_distribuidor(4)),
        const DistribuidorDraft(
          ruc: '1790000004',
          razonSocial: 'Pronaca 4',
          nombreContacto: 'Ana',
          telefono: '0991234567',
          email: 'ventas@pronaca.ec',
          direccion: 'Quito',
          categoriaProveedor: 'Carnes',
        ),
      );
      await cubit.close();
    });

    test(
      'missing optional values become empty and categoria General',
      () async {
        final cubit = build();

        expect(
          cubit.draftFor(
            const Distribuidor(id: 5, ruc: '1790000005', razonSocial: 'Fritz'),
          ),
          const DistribuidorDraft(
            ruc: '1790000005',
            razonSocial: 'Fritz',
            nombreContacto: '',
            telefono: '',
            email: '',
            direccion: '',
            categoriaProveedor: 'General',
          ),
        );
        await cubit.close();
      },
    );
  });

  group('saveDistribuidor', () {
    test('creates a trimmed distribuidor and omits blank optionals', () async {
      when(() => repository.createDistribuidor(any()))
          .thenAnswer((_) async => _distribuidor(9));
      final cubit = build();
      var notified = 0;
      final subscription = changes.stream.listen((_) => notified++);

      final ok = await cubit.saveDistribuidor(_draft);
      await Future<void>.delayed(Duration.zero);

      expect(ok, isTrue);
      verify(
        () => repository.createDistribuidor(
          const DistribuidorDraft(
            ruc: '1790000001001',
            razonSocial: 'Pronaca Cía. Ltda.',
            nombreContacto: 'Ana Pérez',
            email: 'ventas@pronaca.ec',
            categoriaProveedor: 'Carnes',
          ),
        ),
      ).called(1);
      verify(() => repository.getDistribuidores(page: 0, size: 100)).called(1);
      expect(notified, 1);
      await subscription.cancel();
      await cubit.close();
    });

    test('an id updates that distribuidor', () async {
      when(() => repository.updateDistribuidor(any(), any()))
          .thenAnswer((_) async => _distribuidor(4));
      final cubit = build();

      final ok = await cubit.saveDistribuidor(_draft, id: 4);

      expect(ok, isTrue);
      verify(
        () => repository.updateDistribuidor(
          4,
          const DistribuidorDraft(
            ruc: '1790000001001',
            razonSocial: 'Pronaca Cía. Ltda.',
            nombreContacto: 'Ana Pérez',
            email: 'ventas@pronaca.ec',
            categoriaProveedor: 'Carnes',
          ),
        ),
      ).called(1);
      verifyNever(() => repository.createDistribuidor(any()));
      await cubit.close();
    });

    test('rejects a blank RUC or razon social', () async {
      final cubit = build();

      final blankRuc = await cubit.saveDistribuidor(
        const DistribuidorDraft(ruc: '   ', razonSocial: 'Pronaca'),
      );
      expect(blankRuc, isFalse);
      expect(cubit.state.error!.message, 'RUC y Razón Social son obligatorios');

      final blankRazon = await cubit.saveDistribuidor(
        const DistribuidorDraft(ruc: '1790000001001', razonSocial: '  '),
      );
      expect(blankRazon, isFalse);
      expect(cubit.state.error!.message, 'RUC y Razón Social son obligatorios');
      verifyNever(() => repository.createDistribuidor(any()));
      verifyNever(() => repository.updateDistribuidor(any(), any()));
      await cubit.close();
    });

    test('a backend error shows its message', () async {
      when(() => repository.createDistribuidor(any()))
          .thenThrow(const BadRequestException('RUC duplicado'));
      final cubit = build();

      final ok = await cubit.saveDistribuidor(_draft);

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'RUC duplicado');
      await cubit.close();
    });

    test('a backend error without message uses the fallback', () async {
      when(() => repository.createDistribuidor(any()))
          .thenThrow(const BadRequestException(''));
      final cubit = build();

      await cubit.saveDistribuidor(_draft);

      expect(cubit.state.error!.message, 'Error al guardar distribuidor');
      await cubit.close();
    });
  });

  group('deleteDistribuidor', () {
    test('deletes and reloads', () async {
      when(() => repository.deleteDistribuidor(any())).thenAnswer((_) async {});
      final cubit = build();

      final ok = await cubit.deleteDistribuidor(_distribuidor(2));

      expect(ok, isTrue);
      verify(() => repository.deleteDistribuidor(2)).called(1);
      verify(() => repository.getDistribuidores(page: 0, size: 100)).called(1);
      await cubit.close();
    });

    test('an error uses the delete fallback', () async {
      when(() => repository.deleteDistribuidor(any()))
          .thenThrow(const ServerException(''));
      final cubit = build();

      final ok = await cubit.deleteDistribuidor(_distribuidor(2));

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Error al eliminar distribuidor');
      await cubit.close();
    });
  });
}
