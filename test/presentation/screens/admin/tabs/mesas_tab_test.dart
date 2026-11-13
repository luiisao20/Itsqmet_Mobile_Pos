import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/mesas_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockMesas extends Mock implements MesaRepository {}

Mesa _mesa(
  int id, {
  required int numero,
  String? ubicacion = 'Terraza',
  int capacidad = 6,
  EstadoMesa estado = EstadoMesa.libre,
}) => Mesa(
  id: id,
  numeroMesa: numero,
  capacidad: capacidad,
  ubicacion: ubicacion,
  estado: estado,
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
  late _MockMesas mesas;
  late AdminMesasCubit cubit;
  late StreamController<void> createRequests;

  setUpAll(() {
    registerFallbackValue(const MesaDraft(numeroMesa: 0, capacidad: 0));
  });

  setUp(() {
    mesas = _MockMesas();
    createRequests = StreamController<void>.broadcast();
    when(() => mesas.getMesas(page: 0, size: 100)).thenAnswer(
      (_) async => PageResult.single([
        _mesa(1, numero: 3, estado: EstadoMesa.ocupada),
        _mesa(2, numero: 7, ubicacion: null, capacidad: 2),
      ]),
    );
    cubit = AdminMesasCubit(mesaRepository: mesas, changes: AdminChanges());
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
            child: BlocProvider<AdminMesasCubit>.value(
              value: cubit,
              child: AdminMesasView(createRequests: createRequests.stream),
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

  testWidgets('the table shows every column of each mesa', (tester) async {
    await pumpTab(tester);

    expect(find.text('Distribución de Mesas del Salón'), findsOneWidget);
    expect(find.text('2 mesas configuradas'), findsOneWidget);
    for (final header in [
      'MESA #',
      'UBICACIÓN',
      'CAPACIDAD',
      'ESTADO',
      'ACCIONES',
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('Mesa 3'), findsOneWidget);
    expect(find.text('Mesa 7'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Mesa 3')).style?.fontWeight,
      FontWeight.w900,
    );
    expect(find.text('Terraza'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('6 personas'), findsOneWidget);
    expect(find.text('2 personas'), findsOneWidget);
    expect(find.text('Ocupada'), findsOneWidget);
    expect(find.text('Libre'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Eliminar'), findsNWidgets(2));
  });

  testWidgets('an empty list shows the empty message', (tester) async {
    when(() => mesas.getMesas(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const []));
    await pumpTab(tester);

    expect(find.text('No hay mesas registradas'), findsOneWidget);
    expect(find.text('0 mesas configuradas'), findsOneWidget);
  });

  testWidgets('a phone shows the mesas as cards', (tester) async {
    await pumpTab(tester, size: TestScreens.phone);

    expect(find.text('Mesa 3'), findsOneWidget);
    expect(find.text('6 personas'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a create request opens the new mesa form with defaults', (
    tester,
  ) async {
    await pumpTab(tester);

    await openCreate(tester);

    expect(find.text('Nueva Mesa'), findsOneWidget);
    expect(find.text('Número de Mesa *', findRichText: true), findsOneWidget);
    expect(
      find.text('Capacidad (Personas) *', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Ubicación'), findsOneWidget);
    expect(find.text('Ej: Terraza, Salón Principal, Barra'), findsOneWidget);
    expect(find.text('Estado Inicial'), findsOneWidget);
    expect(find.text('Guardar Mesa'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(_fieldText(tester, 'mesa.numero'), '8');
    expect(_fieldText(tester, 'mesa.capacidad'), '4');
    expect(_fieldText(tester, 'mesa.ubicacion'), 'Salón Principal');
    expect(find.text('LIBRE'), findsOneWidget);
  });

  testWidgets('the estado dropdown offers LIBRE, OCUPADA and CUENTA', (
    tester,
  ) async {
    await pumpTab(tester);
    await openCreate(tester);

    await tester.tap(find.text('LIBRE'));
    await tester.pumpAndSettle();

    expect(find.text('OCUPADA'), findsOneWidget);
    expect(find.text('CUENTA'), findsOneWidget);
  });

  testWidgets('saving a new mesa creates it and closes the form', (
    tester,
  ) async {
    when(() => mesas.createMesa(any()))
        .thenAnswer((_) async => _mesa(9, numero: 8));
    await pumpTab(tester);
    await openCreate(tester);

    await tester.enterText(find.byKey(const ValueKey('mesa.capacidad')), '10');
    await tester.enterText(
      find.byKey(const ValueKey('mesa.ubicacion')),
      '  Barra  ',
    );
    await tester.tap(find.text('LIBRE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CUENTA').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar Mesa'));
    await tester.pumpAndSettle();

    verify(
      () => mesas.createMesa(
        const MesaDraft(
          numeroMesa: 8,
          capacidad: 10,
          ubicacion: 'Barra',
          estado: EstadoMesa.cuenta,
        ),
      ),
    ).called(1);
    expect(find.text('Nueva Mesa'), findsNothing);
  });

  testWidgets('an invalid mesa keeps the form open and notifies', (
    tester,
  ) async {
    await pumpTab(tester);
    await openCreate(tester);

    await tester.enterText(find.byKey(const ValueKey('mesa.capacidad')), 'x');
    await tester.tap(find.text('Guardar Mesa'));
    await tester.pumpAndSettle();

    expect(find.text('Nueva Mesa'), findsOneWidget);
    expect(
      find.text('Número de mesa y capacidad deben ser mayores a 0'),
      findsOneWidget,
    );
    verifyNever(() => mesas.createMesa(any()));
  });

  testWidgets('Editar opens the form prefilled and updates that mesa', (
    tester,
  ) async {
    when(() => mesas.updateMesa(any(), any()))
        .thenAnswer((_) async => _mesa(2, numero: 7));
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Editar').last);
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    expect(find.text('Editar Mesa'), findsOneWidget);
    expect(_fieldText(tester, 'mesa.numero'), '7');
    expect(_fieldText(tester, 'mesa.capacidad'), '2');
    expect(_fieldText(tester, 'mesa.ubicacion'), 'Salón Principal');

    await tester.tap(find.text('Guardar Mesa'));
    await tester.pumpAndSettle();

    verify(
      () => mesas.updateMesa(
        2,
        const MesaDraft(
          numeroMesa: 7,
          capacidad: 2,
          ubicacion: 'Salón Principal',
          estado: EstadoMesa.libre,
        ),
      ),
    ).called(1);
    expect(find.text('Editar Mesa'), findsNothing);
  });

  testWidgets('Eliminar asks for confirmation before deleting', (tester) async {
    when(() => mesas.deleteMesa(any())).thenAnswer((_) async {});
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar la Mesa #3?'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Eliminar'));
    await tester.pumpAndSettle();

    verify(() => mesas.deleteMesa(1)).called(1);
  });

  testWidgets('cancelling the confirmation keeps the mesa', (tester) async {
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => mesas.deleteMesa(any()));
  });
}
