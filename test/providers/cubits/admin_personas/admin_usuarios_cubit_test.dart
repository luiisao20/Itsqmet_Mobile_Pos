import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_usuarios_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockUsuarios extends Mock implements UsuarioRepository {}

Usuario _usuario(String uuid, {bool activo = true, Rol rol = Rol.cocina}) =>
    Usuario(
      uuid: uuid,
      nombre: 'Ana $uuid',
      apellido: 'Paz',
      cedula: '17000000$uuid',
      email: 'ana$uuid@mail.com',
      rol: rol,
      activo: activo,
    );

const _draft = UsuarioDraft(
  nombre: '  Ana  ',
  apellido: '  Paz  ',
  cedula: '  1700000001  ',
  email: '  ana@mail.com  ',
  password: '  clave1  ',
  rol: Rol.admin,
  activo: false,
);

const _requiredMessage = 'Completa los campos obligatorios del usuario';
const _passwordMessage =
    'La contraseña temporal debe tener al menos 4 caracteres';

UsuarioDraft _withPassword(String? password) => UsuarioDraft(
  nombre: _draft.nombre,
  apellido: _draft.apellido,
  cedula: _draft.cedula,
  email: _draft.email,
  password: password,
  rol: _draft.rol,
  activo: _draft.activo,
);

void main() {
  late _MockUsuarios usuarios;
  late AdminChanges changes;

  AdminUsuariosCubit build() =>
      AdminUsuariosCubit(usuarioRepository: usuarios, changes: changes);

  setUpAll(() => registerFallbackValue(_draft));

  setUp(() {
    usuarios = _MockUsuarios();
    changes = AdminChanges();
    when(() => usuarios.getUsuarios(page: 0, size: 100)).thenAnswer(
      (_) async => PageResult.single([_usuario('1'), _usuario('2')]),
    );
  });

  test('loads the first 100 usuarios', () async {
    final cubit = build();

    await cubit.load();

    expect(cubit.state.items.map((u) => u.uuid), ['1', '2']);
    verify(() => usuarios.getUsuarios(page: 0, size: 100)).called(1);
    await cubit.close();
  });

  group('draftFor', () {
    test('a new usuario is an active MESERO with an empty password', () async {
      final cubit = build();

      expect(
        cubit.draftFor(null),
        const UsuarioDraft(
          nombre: '',
          apellido: '',
          cedula: '',
          email: '',
          password: '',
          rol: Rol.mesero,
          activo: true,
        ),
      );
      await cubit.close();
    });

    test(
      'an existing usuario copies its values with an empty password',
      () async {
        final cubit = build();

        expect(
          cubit.draftFor(_usuario('4', activo: false)),
          const UsuarioDraft(
            nombre: 'Ana 4',
            apellido: 'Paz',
            cedula: '170000004',
            email: 'ana4@mail.com',
            password: '',
            rol: Rol.cocina,
            activo: false,
          ),
        );
        await cubit.close();
      },
    );
  });

  group('saveUsuario', () {
    test('creates a trimmed usuario with the trimmed password and notifies '
        'the change', () async {
      when(() => usuarios.createUsuario(any()))
          .thenAnswer((_) async => _usuario('9'));
      final cubit = build();
      var notified = 0;
      final subscription = changes.stream.listen((_) => notified++);

      final ok = await cubit.saveUsuario(_draft);
      await pumpEventQueue();

      expect(ok, isTrue);
      verify(
        () => usuarios.createUsuario(
          const UsuarioDraft(
            nombre: 'Ana',
            apellido: 'Paz',
            cedula: '1700000001',
            email: 'ana@mail.com',
            password: 'clave1',
            rol: Rol.admin,
            activo: false,
          ),
        ),
      ).called(1);
      verify(() => usuarios.getUsuarios(page: 0, size: 100)).called(1);
      expect(notified, 1);
      await subscription.cancel();
      await cubit.close();
    });

    test('a new password of four blank characters passes and is not '
        'sent', () async {
      when(() => usuarios.createUsuario(any()))
          .thenAnswer((_) async => _usuario('9'));
      final cubit = build();

      final ok = await cubit.saveUsuario(_withPassword('    '));

      expect(ok, isTrue);
      final sent =
          verify(() => usuarios.createUsuario(captureAny())).captured.single
              as UsuarioDraft;
      expect(sent.password, isNull);
      await cubit.close();
    });

    test('a uuid updates that usuario and omits a blank password', () async {
      when(() => usuarios.updateUsuario(any(), any()))
          .thenAnswer((_) async => _usuario('4'));
      final cubit = build();

      final ok = await cubit.saveUsuario(_withPassword('   '), uuid: '4');

      expect(ok, isTrue);
      verify(
        () => usuarios.updateUsuario(
          '4',
          const UsuarioDraft(
            nombre: 'Ana',
            apellido: 'Paz',
            cedula: '1700000001',
            email: 'ana@mail.com',
            rol: Rol.admin,
            activo: false,
          ),
        ),
      ).called(1);
      verifyNever(() => usuarios.createUsuario(any()));
      await cubit.close();
    });

    test('an update sends a short password without the length rule', () async {
      when(() => usuarios.updateUsuario(any(), any()))
          .thenAnswer((_) async => _usuario('4'));
      final cubit = build();

      final ok = await cubit.saveUsuario(_withPassword(' ab '), uuid: '4');

      expect(ok, isTrue);
      final sent =
          verify(() => usuarios.updateUsuario('4', captureAny()))
                  .captured
                  .single
              as UsuarioDraft;
      expect(sent.password, 'ab');
      await cubit.close();
    });

    for (final field in ['nombre', 'apellido', 'cedula', 'email']) {
      test('a blank $field rejects with the required message', () async {
        final cubit = build();
        final draft = UsuarioDraft(
          nombre: field == 'nombre' ? '   ' : 'Ana',
          apellido: field == 'apellido' ? '   ' : 'Paz',
          cedula: field == 'cedula' ? '   ' : '1700000001',
          email: field == 'email' ? '   ' : 'ana@mail.com',
          password: 'clave1',
          rol: Rol.mesero,
          activo: true,
        );

        final ok = await cubit.saveUsuario(draft, uuid: '4');

        expect(ok, isFalse);
        expect(cubit.state.error!.message, _requiredMessage);
        verifyNever(() => usuarios.updateUsuario(any(), any()));
        await cubit.close();
      });
    }

    test('required fields are checked before the password rule', () async {
      final cubit = build();

      await cubit.saveUsuario(
        const UsuarioDraft(
          nombre: '',
          apellido: 'Paz',
          cedula: '1700000001',
          email: 'ana@mail.com',
          password: '',
          rol: Rol.mesero,
          activo: true,
        ),
      );

      expect(cubit.state.error!.message, _requiredMessage);
      await cubit.close();
    });

    test('a new usuario without a password of four characters is '
        'rejected', () async {
      final cubit = build();

      for (final password in [null, '', 'abc']) {
        final ok = await cubit.saveUsuario(_withPassword(password));
        expect(ok, isFalse, reason: '$password');
        expect(cubit.state.error!.message, _passwordMessage);
      }
      verifyNever(() => usuarios.createUsuario(any()));
      await cubit.close();
    });

    test('a backend error without message uses the fallback', () async {
      when(() => usuarios.createUsuario(any()))
          .thenThrow(const BadRequestException(''));
      final cubit = build();

      final ok = await cubit.saveUsuario(_draft);

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Error al guardar personal');
      await cubit.close();
    });

    test('a backend error message is shown as is', () async {
      when(() => usuarios.createUsuario(any()))
          .thenThrow(const BadRequestException('Email ya registrado'));
      final cubit = build();

      await cubit.saveUsuario(_draft);

      expect(cubit.state.error!.message, 'Email ya registrado');
      await cubit.close();
    });
  });

  group('toggleActivo', () {
    test('updates the usuario with the opposite activo and no '
        'password', () async {
      when(() => usuarios.updateUsuario(any(), any()))
          .thenAnswer((_) async => _usuario('1', activo: false));
      final cubit = build();

      final ok = await cubit.toggleActivo(_usuario('1'));

      expect(ok, isTrue);
      verify(
        () => usuarios.updateUsuario(
          '1',
          const UsuarioDraft(
            nombre: 'Ana 1',
            apellido: 'Paz',
            cedula: '170000001',
            email: 'ana1@mail.com',
            rol: Rol.cocina,
            activo: false,
          ),
        ),
      ).called(1);
      verify(() => usuarios.getUsuarios(page: 0, size: 100)).called(1);
      await cubit.close();
    });

    test('an error uses the estado fallback', () async {
      when(() => usuarios.updateUsuario(any(), any()))
          .thenThrow(const ServerException(' '));
      final cubit = build();

      final ok = await cubit.toggleActivo(_usuario('1'));

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Error al cambiar estado');
      await cubit.close();
    });
  });

  group('deleteUsuario', () {
    test('deletes by uuid and reloads', () async {
      when(() => usuarios.deleteUsuario(any())).thenAnswer((_) async {});
      final cubit = build();

      final ok = await cubit.deleteUsuario(_usuario('2'));

      expect(ok, isTrue);
      verify(() => usuarios.deleteUsuario('2')).called(1);
      verify(() => usuarios.getUsuarios(page: 0, size: 100)).called(1);
      await cubit.close();
    });

    test('an error uses the delete fallback', () async {
      when(() => usuarios.deleteUsuario(any()))
          .thenThrow(const ServerException(''));
      final cubit = build();

      final ok = await cubit.deleteUsuario(_usuario('2'));

      expect(ok, isFalse);
      expect(cubit.state.error!.message, 'Error al eliminar usuario');
      await cubit.close();
    });
  });
}
