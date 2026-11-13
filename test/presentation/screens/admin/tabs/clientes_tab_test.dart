import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/clientes_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_clientes_cubit.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockClientes extends Mock implements ClienteRepository {}

const _andina = Cliente(
  uuid: 'uuid-1',
  tipoIdentificacion: TipoIdentificacion.ruc,
  identificacion: '1790012345001',
  razonSocial: 'Comercial Andina S.A.',
  direccion: 'Av. Amazonas N24',
  telefono: '022345678',
  email: 'ventas@andina.ec',
  activo: true,
);

const _juan = Cliente(
  uuid: 'uuid-2',
  tipoIdentificacion: TipoIdentificacion.cedula,
  identificacion: '1712345678',
  razonSocial: 'Juan Perez',
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

TextInputType _keyboard(WidgetTester tester, String key) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(EditableText),
      ),
    )
    .keyboardType;

void main() {
  late _MockClientes clientes;
  late AdminClientesCubit cubit;
  late StreamController<void> createRequests;

  setUpAll(() {
    registerFallbackValue(
      const ClienteDraft(
        tipoIdentificacion: TipoIdentificacion.cedula,
        identificacion: '',
        razonSocial: '',
      ),
    );
  });

  setUp(() {
    clientes = _MockClientes();
    createRequests = StreamController<void>.broadcast();
    when(() => clientes.getClientes(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const [_andina, _juan]));
    cubit = AdminClientesCubit(
      clienteRepository: clientes,
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
            child: BlocProvider<AdminClientesCubit>.value(
              value: cubit,
              child: ClientesView(createRequests: createRequests.stream),
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

  testWidgets('the table shows every column of each cliente', (tester) async {
    await pumpTab(tester);

    expect(find.text('Directorio de Clientes Registrados'), findsOneWidget);
    expect(find.text('2 clientes'), findsOneWidget);
    for (final header in [
      'RAZÓN SOCIAL / NOMBRE',
      'TIPO & IDENTIFICACIÓN',
      'EMAIL',
      'TELÉFONO',
      'ACCIONES',
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('Comercial Andina S.A.'), findsOneWidget);
    expect(find.text('RUC'), findsOneWidget);
    expect(find.text('1790012345001'), findsOneWidget);
    expect(find.text('ventas@andina.ec'), findsOneWidget);
    expect(find.text('022345678'), findsOneWidget);
    expect(find.text('Juan Perez'), findsOneWidget);
    expect(find.text('CEDULA'), findsOneWidget);
    expect(find.text('1712345678'), findsOneWidget);
    expect(find.text('-'), findsNWidgets(2));
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Eliminar'), findsNWidgets(2));
  });

  testWidgets('the tipo is small bold gray over a mono identificacion', (
    tester,
  ) async {
    await pumpTab(tester);

    final tipo = tester.widget<Text>(find.text('RUC'));
    expect(tipo.style!.fontSize, 10);
    expect(tipo.style!.fontWeight, FontWeight.w700);
    expect(tipo.style!.color, AppColors.gray400);
    final identificacion = tester.widget<Text>(find.text('1790012345001'));
    expect(identificacion.style!.fontFamily, AppTextStyles.mono.fontFamily);
    expect(identificacion.style!.color, AppColors.gray700);
  });

  testWidgets('an empty list shows the empty message', (tester) async {
    when(() => clientes.getClientes(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const []));
    await pumpTab(tester);

    expect(find.text('No hay clientes registrados'), findsOneWidget);
    expect(find.text('0 clientes'), findsOneWidget);
  });

  testWidgets('a phone shows the clientes as cards', (tester) async {
    await pumpTab(tester, size: TestScreens.phone);

    expect(find.text('Comercial Andina S.A.'), findsOneWidget);
    expect(find.text('Juan Perez'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a create request opens the new cliente form with defaults', (
    tester,
  ) async {
    await pumpTab(tester);

    await openCreate(tester);

    expect(find.text('Nuevo Cliente'), findsOneWidget);
    expect(
      find.text('Razón Social o Nombre *', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text('Tipo de Identificación *', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Identificación *', findRichText: true), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Teléfono'), findsOneWidget);
    expect(find.text('Dirección'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Guardar Cliente'), findsOneWidget);
    expect(find.text('CÉDULA'), findsOneWidget);
    expect(_fieldText(tester, 'cliente.razonSocial'), '');
    expect(_fieldText(tester, 'cliente.identificacion'), '');
    expect(_keyboard(tester, 'cliente.email'), TextInputType.emailAddress);
    expect(_keyboard(tester, 'cliente.telefono'), TextInputType.phone);
  });

  testWidgets('the tipo dropdown offers the four identification types', (
    tester,
  ) async {
    await pumpTab(tester);
    await openCreate(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('cliente.tipo')),
        matching: find.byType(DropdownButton<TipoIdentificacion>),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['CÉDULA', 'RUC', 'PASAPORTE', 'CONSUMIDOR FINAL']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    final menuLabels = tester
        .widgetList<DropdownMenuItem<TipoIdentificacion>>(
          find.byType(DropdownMenuItem<TipoIdentificacion>),
        )
        .map((item) => (item.child as Text).data)
        .toSet()
        .toList();
    expect(menuLabels, ['CÉDULA', 'RUC', 'PASAPORTE', 'CONSUMIDOR FINAL']);
  });

  testWidgets('saving a new cliente creates it and closes the form', (
    tester,
  ) async {
    when(() => clientes.createCliente(any())).thenAnswer((_) async => _andina);
    await pumpTab(tester);
    await openCreate(tester);

    await tester.enterText(
      find.byKey(const ValueKey('cliente.razonSocial')),
      ' Maria Lopez ',
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('cliente.tipo')),
        matching: find.byType(DropdownButton<TipoIdentificacion>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('PASAPORTE').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('cliente.identificacion')),
      ' AB12345 ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('cliente.email')),
      ' maria@mail.com ',
    );
    await tester.tap(find.text('Guardar Cliente'));
    await tester.pumpAndSettle();

    verify(
      () => clientes.createCliente(
        const ClienteDraft(
          tipoIdentificacion: TipoIdentificacion.pasaporte,
          identificacion: 'AB12345',
          razonSocial: 'Maria Lopez',
          email: 'maria@mail.com',
        ),
      ),
    ).called(1);
    expect(find.text('Nuevo Cliente'), findsNothing);
  });

  testWidgets('an invalid cliente keeps the form open and notifies', (
    tester,
  ) async {
    await pumpTab(tester);
    await openCreate(tester);

    await tester.tap(find.text('Guardar Cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Cliente'), findsOneWidget);
    expect(
      find.text('Identificación y Razón Social son obligatorias'),
      findsOneWidget,
    );
    verifyNever(() => clientes.createCliente(any()));
  });

  testWidgets('Editar opens the form prefilled and updates that cliente', (
    tester,
  ) async {
    when(() => clientes.updateCliente(any(), any()))
        .thenAnswer((_) async => _andina);
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Editar').first);
    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();

    expect(find.text('Editar Cliente'), findsOneWidget);
    expect(_fieldText(tester, 'cliente.razonSocial'), 'Comercial Andina S.A.');
    expect(_fieldText(tester, 'cliente.identificacion'), '1790012345001');
    expect(_fieldText(tester, 'cliente.email'), 'ventas@andina.ec');
    expect(_fieldText(tester, 'cliente.telefono'), '022345678');
    expect(_fieldText(tester, 'cliente.direccion'), 'Av. Amazonas N24');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('cliente.tipo')),
        matching: find.text('RUC'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Guardar Cliente'));
    await tester.pumpAndSettle();

    verify(
      () => clientes.updateCliente(
        'uuid-1',
        const ClienteDraft(
          tipoIdentificacion: TipoIdentificacion.ruc,
          identificacion: '1790012345001',
          razonSocial: 'Comercial Andina S.A.',
          direccion: 'Av. Amazonas N24',
          telefono: '022345678',
          email: 'ventas@andina.ec',
        ),
      ),
    ).called(1);
    verifyNever(() => clientes.createCliente(any()));
    expect(find.text('Editar Cliente'), findsNothing);
  });

  testWidgets('Eliminar asks for confirmation before deleting', (tester) async {
    when(() => clientes.deleteCliente(any())).thenAnswer((_) async {});
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();

    expect(
      find.text('¿Eliminar al cliente "Comercial Andina S.A."?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(AppButton, 'Eliminar'));
    await tester.pumpAndSettle();

    verify(() => clientes.deleteCliente('uuid-1')).called(1);
  });

  testWidgets('cancelling the confirmation keeps the cliente', (tester) async {
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => clientes.deleteCliente(any()));
  });
}
