import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_clientes_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockClientes extends Mock implements ClienteRepository {}

Cliente _cliente(String uuid, {String? email, String? telefono}) => Cliente(
  uuid: uuid,
  tipoIdentificacion: TipoIdentificacion.ruc,
  identificacion: '179000000${uuid}001',
  razonSocial: 'Cliente $uuid',
  direccion: null,
  telefono: telefono,
  email: email,
  activo: true,
);

const _draft = ClienteDraft(
  tipoIdentificacion: TipoIdentificacion.pasaporte,
  identificacion: '  AB12345  ',
  razonSocial: '  Juan Perez  ',
  direccion: '  Av. Amazonas  ',
  telefono: '   ',
  email: '  juan@mail.com  ',
);

void main() {
  late _MockClientes clientes;
  late AdminChanges changes;

  AdminClientesCubit build() =>
      AdminClientesCubit(clienteRepository: clientes, changes: changes);

  setUpAll(() => registerFallbackValue(_draft));

  setUp(() {
    clientes = _MockClientes();
    changes = AdminChanges();
    when(() => clientes.getClientes(page: 0, size: 100)).thenAnswer(
      (_) async => PageResult.single([_cliente('a'), _cliente('b')]),
    );
  });

  test('loads the first 100 clientes', () async {
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items.map((c) => c.uuid), ['a', 'b']);
    verify(() => clientes.getClientes(page: 0, size: 100)).called(1);
    await cubit.close();
  });

  group('draftFor', () {
    test('a new cliente uses CEDULA and empty fields', () async {
      final cubit = build();

      expect(
        cubit.draftFor(null),
        const ClienteDraft(
          tipoIdentificacion: TipoIdentificacion.cedula,
          identificacion: '',
          razonSocial: '',
          direccion: '',
          telefono: '',
          email: '',
        ),
      );
      await cubit.close();
    });

    test(
      'an existing cliente copies its values with blank fallbacks',
      () async {
        final cubit = build();

        expect(
          cubit.draftFor(_cliente('c', email: 'c@mail.com')),
          const ClienteDraft(
            tipoIdentificacion: TipoIdentificacion.ruc,
            identificacion: '179000000c001',
            razonSocial: 'Cliente c',
            direccion: '',
            telefono: '',
            email: 'c@mail.com',
          ),
        );
        await cubit.close();
      },
    );
  });

  group('saveCliente', () {
    test('creates a trimmed cliente, omits blank optionals and sends no '
        'password or activo', () async {
      when(() => clientes.createCliente(any()))
          .thenAnswer((_) async => _cliente('n'));
      final cubit = build();
      final notified = expectLater(changes.stream, emits(null));

      final ok = await cubit.saveCliente(
        const ClienteDraft(
          tipoIdentificacion: TipoIdentificacion.pasaporte,
          identificacion: '  AB12345  ',
          razonSocial: '  Juan Perez  ',
          direccion: '  Av. Amazonas  ',
          telefono: '   ',
          email: '  juan@mail.com  ',
          password: 'secret',
          activo: false,
        ),
      );

      expect(ok, isTrue);
      verify(
        () => clientes.createCliente(
          const ClienteDraft(
            tipoIdentificacion: TipoIdentificacion.pasaporte,
            identificacion: 'AB12345',
            razonSocial: 'Juan Perez',
            direccion: 'Av. Amazonas',
            email: 'juan@mail.com',
          ),
        ),
      ).called(1);
      verify(() => clientes.getClientes(page: 0, size: 100)).called(1);
      await notified;
      await cubit.close();
    });

    test('a uuid updates that cliente', () async {
      when(() => clientes.updateCliente(any(), any()))
          .thenAnswer((_) async => _cliente('a'));
      final cubit = build();

      final ok = await cubit.saveCliente(_draft, uuid: 'a');

      expect(ok, isTrue);
      verify(
        () => clientes.updateCliente(
          'a',
          const ClienteDraft(
            tipoIdentificacion: TipoIdentificacion.pasaporte,
            identificacion: 'AB12345',
            razonSocial: 'Juan Perez',
            direccion: 'Av. Amazonas',
            email: 'juan@mail.com',
          ),
        ),
      ).called(1);
      verifyNever(() => clientes.createCliente(any()));
      await cubit.close();
    });

    test('rejects a blank identificacion or razon social', () async {
      final cubit = build();

      final blankId = await cubit.saveCliente(
        const ClienteDraft(
          tipoIdentificacion: TipoIdentificacion.cedula,
          identificacion: '   ',
          razonSocial: 'Juan',
        ),
      );
      expect(blankId, isFalse);
      expect(
        cubit.state.error!.message,
        'Identificación y Razón Social son obligatorias',
      );

      final blankRazon = await cubit.saveCliente(
        const ClienteDraft(
          tipoIdentificacion: TipoIdentificacion.cedula,
          identificacion: '1700000001',
          razonSocial: '  ',
        ),
      );
      expect(blankRazon, isFalse);
      verifyNever(() => clientes.createCliente(any()));
      verifyNever(() => clientes.updateCliente(any(), any()));
      await cubit.close();
    });

    test('a backend message is shown as is', () async {
      when(() => clientes.createCliente(any()))
          .thenThrow(const BadRequestException('Identificación duplicada'));
      final cubit = build();

      final ok = await cubit.saveCliente(_draft);

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Identificación duplicada');
      await cubit.close();
    });

    test('a backend error without message uses the fallback', () async {
      when(() => clientes.createCliente(any()))
          .thenThrow(const BadRequestException(''));
      final cubit = build();

      await cubit.saveCliente(_draft);

      expect(cubit.state.error!.message, 'Error al guardar cliente');
      await cubit.close();
    });
  });

  group('deleteCliente', () {
    test('deletes by uuid and reloads', () async {
      when(() => clientes.deleteCliente(any())).thenAnswer((_) async {});
      final cubit = build();
      final notified = expectLater(changes.stream, emits(null));

      final ok = await cubit.deleteCliente(_cliente('b'));

      expect(ok, isTrue);
      verify(() => clientes.deleteCliente('b')).called(1);
      verify(() => clientes.getClientes(page: 0, size: 100)).called(1);
      await notified;
      await cubit.close();
    });

    test('an error uses the delete fallback', () async {
      when(() => clientes.deleteCliente(any()))
          .thenThrow(const ServerException(''));
      final cubit = build();

      await cubit.deleteCliente(_cliente('b'));

      expect(cubit.state.error!.message, 'Error al eliminar cliente');
      await cubit.close();
    });
  });
}
