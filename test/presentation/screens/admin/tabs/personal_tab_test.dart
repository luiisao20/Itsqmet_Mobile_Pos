import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/personal_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/role_chip.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_usuarios_cubit.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockUsuarios extends Mock implements UsuarioRepository {}

const _ana = Usuario(
  uuid: 'u-1',
  nombre: 'Ana',
  apellido: 'Paz',
  cedula: '1700000001',
  email: 'ana@mail.com',
  rol: Rol.cocina,
  activo: true,
);

const _luis = Usuario(
  uuid: 'u-2',
  nombre: 'Luis',
  apellido: 'Mora',
  cedula: '1700000002',
  email: 'luis@mail.com',
  rol: Rol.admin,
  activo: false,
);

String _fieldText(WidgetTester tester, String key) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

void main() {
  late _MockUsuarios usuarios;
  late AdminUsuariosCubit cubit;
  late StreamController<void> createRequests;

  setUpAll(() {
    registerFallbackValue(
      const UsuarioDraft(
        nombre: '',
        apellido: '',
        cedula: '',
        email: '',
        rol: Rol.mesero,
        activo: true,
      ),
    );
  });

  setUp(() {
    usuarios = _MockUsuarios();
    createRequests = StreamController<void>.broadcast();
    when(() => usuarios.getUsuarios(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const [_ana, _luis]));
    cubit = AdminUsuariosCubit(
      usuarioRepository: usuarios,
      changes: AdminChanges(),
    );
  });

  tearDown(() async {
    await cubit.close();
    await createRequests.close();
  });

  Future<void> pumpTab(
    WidgetTester tester, {
    Size size = TestScreens.tabletLandscape,
  }) async {
    tester.setScreenSize(size);
    await cubit.load();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        scaffoldMessengerKey: NotificationsService.messengerKey,
        home: Scaffold(
          body: SingleChildScrollView(
            child: BlocProvider<AdminUsuariosCubit>.value(
              value: cubit,
              child: PersonalView(createRequests: createRequests.stream),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openCreate(WidgetTester tester) async {
    createRequests.add(null);
    await tester.pumpAndSettle();
  }

  testWidgets('the table shows every column of each usuario', (tester) async {
    await pumpTab(tester);

    expect(find.text('Personal del Restaurante'), findsOneWidget);
    expect(find.text('2 empleados'), findsOneWidget);
    for (final header in [
      'NOMBRE',
      'CÉDULA',
      'EMAIL',
      'ROL',
      'ESTADO',
      'ACCIONES',
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('Ana Paz'), findsOneWidget);
    expect(find.text('Luis Mora'), findsOneWidget);
    expect(find.text('1700000001'), findsOneWidget);
    expect(find.text('luis@mail.com'), findsOneWidget);
    expect(find.widgetWithText(RoleChip, 'COCINA'), findsOneWidget);
    expect(find.widgetWithText(RoleChip, 'ADMIN'), findsOneWidget);
    expect(find.text('Activo'), findsOneWidget);
    expect(find.text('Inactivo'), findsOneWidget);
    expect(find.byTooltip('Cambiar activo'), findsNWidgets(2));
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Eliminar'), findsNWidgets(2));
  });

  testWidgets('an empty list shows the empty message', (tester) async {
    when(() => usuarios.getUsuarios(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const []));
    await pumpTab(tester);

    expect(find.text('No hay empleados registrados'), findsOneWidget);
    expect(find.text('0 empleados'), findsOneWidget);
  });

  testWidgets('a phone shows the usuarios as cards', (tester) async {
    await pumpTab(tester, size: TestScreens.phone);

    expect(find.text('Ana Paz'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a create request opens the new empleado form with defaults', (
    tester,
  ) async {
    await pumpTab(tester);

    await openCreate(tester);

    expect(find.text('Nuevo Empleado'), findsOneWidget);
    for (final label in [
      'Nombre *',
      'Apellido *',
      'Cédula *',
      'Rol Operativo *',
      'Email *',
      'Contraseña *',
    ]) {
      expect(
        find.text(label, findRichText: true),
        findsOneWidget,
        reason: label,
      );
    }
    expect(
      find.text(
        'Contraseña (Dejar en blanco para no modificar)',
        findRichText: true,
      ),
      findsNothing,
    );
    expect(find.text('Mínimo 4 caracteres'), findsOneWidget);
    expect(find.text('Usuario Activo'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Guardar Empleado'), findsOneWidget);
    expect(find.text('MESERO'), findsOneWidget);
    expect(_fieldText(tester, 'usuario.password'), '');
    final password = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('usuario.password')),
        matching: find.byType(EditableText),
      ),
    );
    expect(password.obscureText, isTrue);
    final dropdown = tester.widget<DropdownButton<Rol>>(
      find.byType(DropdownButton<Rol>),
    );
    expect(dropdown.value, Rol.mesero);
    expect(dropdown.items!.map((item) => item.value), [
      Rol.mesero,
      Rol.cocina,
      Rol.admin,
      Rol.cliente,
    ]);
  });

  testWidgets('saving a new empleado creates it and closes the form', (
    tester,
  ) async {
    when(() => usuarios.createUsuario(any())).thenAnswer((_) async => _ana);
    await pumpTab(tester);
    await openCreate(tester);

    await tester.enterText(
      find.byKey(const ValueKey('usuario.nombre')),
      ' Eva ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('usuario.apellido')),
      ' Ruiz ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('usuario.cedula')),
      ' 1700000003 ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('usuario.email')),
      ' eva@mail.com ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('usuario.password')),
      ' clave1 ',
    );
    await tester.tap(find.byType(DropdownButton<Rol>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COCINA').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usuario Activo'));
    await tester.tap(find.text('Guardar Empleado'));
    await tester.pumpAndSettle();

    verify(
      () => usuarios.createUsuario(
        const UsuarioDraft(
          nombre: 'Eva',
          apellido: 'Ruiz',
          cedula: '1700000003',
          email: 'eva@mail.com',
          password: 'clave1',
          rol: Rol.cocina,
          activo: false,
        ),
      ),
    ).called(1);
    expect(find.text('Nuevo Empleado'), findsNothing);
  });

  testWidgets('an invalid empleado keeps the form open and notifies', (
    tester,
  ) async {
    await pumpTab(tester);
    await openCreate(tester);

    await tester.tap(find.text('Guardar Empleado'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Empleado'), findsOneWidget);
    expect(
      find.text('Completa los campos obligatorios del usuario'),
      findsOneWidget,
    );
    verifyNever(() => usuarios.createUsuario(any()));
  });

  testWidgets('a new empleado with a short password keeps the form open', (
    tester,
  ) async {
    await pumpTab(tester);
    await openCreate(tester);

    await tester.enterText(find.byKey(const ValueKey('usuario.nombre')), 'Eva');
    await tester.enterText(
      find.byKey(const ValueKey('usuario.apellido')),
      'Ruiz',
    );
    await tester.enterText(
      find.byKey(const ValueKey('usuario.cedula')),
      '1700000003',
    );
    await tester.enterText(
      find.byKey(const ValueKey('usuario.email')),
      'eva@mail.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('usuario.password')),
      'abc',
    );
    await tester.tap(find.text('Guardar Empleado'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Empleado'), findsOneWidget);
    expect(
      find.text('La contraseña temporal debe tener al menos 4 caracteres'),
      findsOneWidget,
    );
    verifyNever(() => usuarios.createUsuario(any()));
  });

  testWidgets('Editar opens the form prefilled and updates that usuario', (
    tester,
  ) async {
    when(() => usuarios.updateUsuario(any(), any()))
        .thenAnswer((_) async => _ana);
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Editar').first);
    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();

    expect(find.text('Editar Empleado'), findsOneWidget);
    expect(
      find.text(
        'Contraseña (Dejar en blanco para no modificar)',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Contraseña *', findRichText: true), findsNothing);
    expect(_fieldText(tester, 'usuario.nombre'), 'Ana');
    expect(_fieldText(tester, 'usuario.apellido'), 'Paz');
    expect(_fieldText(tester, 'usuario.cedula'), '1700000001');
    expect(_fieldText(tester, 'usuario.email'), 'ana@mail.com');
    expect(_fieldText(tester, 'usuario.password'), '');

    await tester.tap(find.text('Guardar Empleado'));
    await tester.pumpAndSettle();

    verify(
      () => usuarios.updateUsuario(
        'u-1',
        const UsuarioDraft(
          nombre: 'Ana',
          apellido: 'Paz',
          cedula: '1700000001',
          email: 'ana@mail.com',
          rol: Rol.cocina,
          activo: true,
        ),
      ),
    ).called(1);
    expect(find.text('Editar Empleado'), findsNothing);
  });

  testWidgets('Eliminar asks for confirmation before deleting', (tester) async {
    when(() => usuarios.deleteUsuario(any())).thenAnswer((_) async {});
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar al empleado Ana Paz?'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Eliminar'));
    await tester.pumpAndSettle();

    verify(() => usuarios.deleteUsuario('u-1')).called(1);
  });

  testWidgets('cancelling the confirmation keeps the usuario', (tester) async {
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => usuarios.deleteUsuario(any()));
  });

  testWidgets('tapping the estado badge toggles activo', (tester) async {
    when(() => usuarios.updateUsuario(any(), any()))
        .thenAnswer((_) async => _luis);
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Inactivo'));
    await tester.tap(find.text('Inactivo'));
    await tester.pumpAndSettle();

    final draft =
        verify(() => usuarios.updateUsuario('u-2', captureAny()))
                .captured
                .single
            as UsuarioDraft;
    expect(draft.activo, isTrue);
    expect(draft.password, isNull);
    expect(draft.rol, Rol.admin);
  });

  testWidgets('a failed toggle notifies the estado error', (tester) async {
    when(() => usuarios.updateUsuario(any(), any()))
        .thenThrow(const ServerException(''));
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Activo'));
    await tester.tap(find.text('Activo'));
    await tester.pumpAndSettle();

    expect(find.text('Error al cambiar estado'), findsOneWidget);
  });
}
