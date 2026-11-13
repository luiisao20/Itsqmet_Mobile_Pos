import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/distribuidores_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/distribuidores_cubit.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockDistribuidores extends Mock implements DistribuidorRepository {}

const _pronaca = Distribuidor(
  id: 1,
  ruc: '1790000001001',
  razonSocial: 'Pronaca',
  nombreContacto: 'Ana Pérez',
  telefono: '0991234567',
  email: 'ventas@pronaca.ec',
  direccion: 'Quito',
  categoriaProveedor: 'Carnes',
);

const _fritz = Distribuidor(id: 2, ruc: '1790000002001', razonSocial: 'Fritz');

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
  late _MockDistribuidores repository;
  late DistribuidoresCubit cubit;
  late StreamController<void> createRequests;

  setUpAll(() {
    registerFallbackValue(const DistribuidorDraft(ruc: '', razonSocial: ''));
  });

  setUp(() {
    repository = _MockDistribuidores();
    createRequests = StreamController<void>.broadcast();
    when(() => repository.getDistribuidores(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single([_pronaca, _fritz]));
    cubit = DistribuidoresCubit(
      distribuidorRepository: repository,
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
            child: BlocProvider<DistribuidoresCubit>.value(
              value: cubit,
              child: DistribuidoresView(createRequests: createRequests.stream),
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

  testWidgets('the table shows every column of each distribuidor', (
    tester,
  ) async {
    await pumpTab(tester);

    expect(
      find.text('Directorio de Distribuidores y Proveedores'),
      findsOneWidget,
    );
    expect(find.text('2 proveedores'), findsOneWidget);
    for (final header in [
      'RAZÓN SOCIAL',
      'RUC',
      'CONTACTO',
      'TELÉFONO / EMAIL',
      'CATEGORÍA',
      'ACCIONES',
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('Pronaca'), findsOneWidget);
    expect(find.text('1790000001001'), findsOneWidget);
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('0991234567'), findsOneWidget);
    expect(find.text('ventas@pronaca.ec'), findsOneWidget);
    expect(find.text('Carnes'), findsOneWidget);
    expect(find.text('Fritz'), findsOneWidget);
    expect(find.text('1790000002001'), findsOneWidget);
    expect(find.text('-'), findsNWidgets(3));
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Eliminar'), findsNWidgets(2));
  });

  testWidgets('an empty list shows the empty message', (tester) async {
    when(() => repository.getDistribuidores(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const []));
    await pumpTab(tester);

    expect(find.text('No hay distribuidores registrados'), findsOneWidget);
    expect(find.text('0 proveedores'), findsOneWidget);
  });

  testWidgets('a phone shows the distribuidores as cards', (tester) async {
    await pumpTab(tester, size: TestScreens.phone);

    expect(find.text('Pronaca'), findsOneWidget);
    expect(find.text('Fritz'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a create request opens the new distribuidor form', (
    tester,
  ) async {
    await pumpTab(tester);

    await openCreate(tester);

    expect(find.text('Nuevo Distribuidor'), findsOneWidget);
    expect(find.text('Razón Social *', findRichText: true), findsOneWidget);
    expect(find.text('Ej: Pronaca Cía. Ltda.'), findsOneWidget);
    expect(find.text('RUC *', findRichText: true), findsOneWidget);
    expect(find.text('Categoría'), findsOneWidget);
    expect(find.text('Ej: Carnes, Lácteos, Abarrotes'), findsOneWidget);
    expect(find.text('Contacto'), findsOneWidget);
    expect(find.text('Teléfono'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Dirección'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Guardar Distribuidor'), findsOneWidget);
    expect(_fieldText(tester, 'distribuidor.categoria'), 'Alimentos');
    expect(_fieldText(tester, 'distribuidor.razonSocial'), '');
    expect(_fieldText(tester, 'distribuidor.ruc'), '');
  });

  testWidgets('saving a new distribuidor creates it and closes the form', (
    tester,
  ) async {
    when(() => repository.createDistribuidor(any()))
        .thenAnswer((_) async => _pronaca);
    await pumpTab(tester);
    await openCreate(tester);

    await tester.enterText(
      find.byKey(const ValueKey('distribuidor.razonSocial')),
      ' Pronaca Cía. Ltda. ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('distribuidor.ruc')),
      ' 1790000001001 ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('distribuidor.telefono')),
      ' 0991234567 ',
    );
    await tester.tap(find.text('Guardar Distribuidor'));
    await tester.pumpAndSettle();

    verify(
      () => repository.createDistribuidor(
        const DistribuidorDraft(
          ruc: '1790000001001',
          razonSocial: 'Pronaca Cía. Ltda.',
          telefono: '0991234567',
          categoriaProveedor: 'Alimentos',
        ),
      ),
    ).called(1);
    expect(find.text('Nuevo Distribuidor'), findsNothing);
  });

  testWidgets('an invalid distribuidor keeps the form open and notifies', (
    tester,
  ) async {
    await pumpTab(tester);
    await openCreate(tester);

    await tester.tap(find.text('Guardar Distribuidor'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Distribuidor'), findsOneWidget);
    expect(find.text('RUC y Razón Social son obligatorios'), findsOneWidget);
    verifyNever(() => repository.createDistribuidor(any()));
  });

  testWidgets('Editar opens the form prefilled and updates that distribuidor', (
    tester,
  ) async {
    when(() => repository.updateDistribuidor(any(), any()))
        .thenAnswer((_) async => _pronaca);
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Editar').first);
    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();

    expect(find.text('Editar Distribuidor'), findsOneWidget);
    expect(_fieldText(tester, 'distribuidor.razonSocial'), 'Pronaca');
    expect(_fieldText(tester, 'distribuidor.ruc'), '1790000001001');
    expect(_fieldText(tester, 'distribuidor.categoria'), 'Carnes');
    expect(_fieldText(tester, 'distribuidor.contacto'), 'Ana Pérez');
    expect(_fieldText(tester, 'distribuidor.telefono'), '0991234567');
    expect(_fieldText(tester, 'distribuidor.email'), 'ventas@pronaca.ec');
    expect(_fieldText(tester, 'distribuidor.direccion'), 'Quito');

    await tester.tap(find.text('Guardar Distribuidor'));
    await tester.pumpAndSettle();

    verify(
      () => repository.updateDistribuidor(
        1,
        const DistribuidorDraft(
          ruc: '1790000001001',
          razonSocial: 'Pronaca',
          nombreContacto: 'Ana Pérez',
          telefono: '0991234567',
          email: 'ventas@pronaca.ec',
          direccion: 'Quito',
          categoriaProveedor: 'Carnes',
        ),
      ),
    ).called(1);
    expect(find.text('Editar Distribuidor'), findsNothing);
  });

  testWidgets('Editar falls back to categoria General', (tester) async {
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Editar').last);
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    expect(_fieldText(tester, 'distribuidor.categoria'), 'General');
    expect(_fieldText(tester, 'distribuidor.contacto'), '');
  });

  testWidgets('Eliminar asks for confirmation before deleting', (tester) async {
    when(() => repository.deleteDistribuidor(any())).thenAnswer((_) async {});
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar al proveedor "Pronaca"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Eliminar'));
    await tester.pumpAndSettle();

    verify(() => repository.deleteDistribuidor(1)).called(1);
  });

  testWidgets('cancelling the confirmation keeps the distribuidor', (
    tester,
  ) async {
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.deleteDistribuidor(any()));
  });
}
