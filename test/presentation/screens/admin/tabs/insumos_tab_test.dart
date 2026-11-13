import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/insumos_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/app_badge.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockInsumos extends Mock implements InsumoRepository {}

const _tomate = Insumo(
  id: 1,
  nombre: 'Tomate Riñón',
  unidadMedida: UnidadMedida.kg,
  stockActual: 2.5,
  stockMinimo: 3,
  costoPromedio: 0.85,
  stockBajo: false,
);

const _aceite = Insumo(
  id: 2,
  nombre: 'Aceite',
  unidadMedida: UnidadMedida.lt,
  stockActual: 10,
  stockMinimo: 5,
  costoPromedio: 1,
  stockBajo: true,
);

void main() {
  late _MockInsumos insumos;
  late InsumosCubit cubit;
  late StreamController<void> createRequests;

  setUpAll(() {
    registerFallbackValue(
      const InsumoDraft(
        nombre: '',
        unidadMedida: UnidadMedida.unidad,
        stockActual: 0,
        stockMinimo: 0,
        costoPromedio: 0,
      ),
    );
  });

  setUp(() {
    insumos = _MockInsumos();
    createRequests = StreamController<void>.broadcast();
    when(() => insumos.getInsumos(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const [_tomate, _aceite]));
    cubit = InsumosCubit(insumoRepository: insumos, changes: AdminChanges());
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
            child: BlocProvider<InsumosCubit>.value(
              value: cubit,
              child: InsumosView(createRequests: createRequests.stream),
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

  String fieldText(WidgetTester tester, String key) => tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(EditableText),
        ),
      )
      .controller
      .text;

  testWidgets('the table shows every column of each insumo', (tester) async {
    await pumpTab(tester);

    expect(find.text('Control de Stock e Insumos'), findsOneWidget);
    expect(find.text('2 insumos registrados'), findsOneWidget);
    for (final header in [
      'INSUMO',
      'UNIDAD',
      'STOCK ACTUAL',
      'STOCK MÍNIMO',
      'COSTO PROMEDIO',
      'ALERTA',
      'ACCIONES',
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('Tomate Riñón'), findsOneWidget);
    expect(find.text('Aceite'), findsOneWidget);
    expect(find.text('KG'), findsOneWidget);
    expect(find.text('UNIDAD'), findsOneWidget);
    expect(find.text('LT'), findsOneWidget);
    expect(find.text('2.5'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('\$0.85'), findsOneWidget);
    expect(find.text('\$1.00'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Eliminar'), findsNWidgets(2));
  });

  testWidgets('the alert and stock colour come from the stock numbers', (
    tester,
  ) async {
    await pumpTab(tester);

    final bajo = tester.widget<AppBadge>(
      find.widgetWithText(AppBadge, 'Stock Bajo'),
    );
    final normal = tester.widget<AppBadge>(
      find.widgetWithText(AppBadge, 'Normal'),
    );
    expect(bajo.variant, BadgeVariant.danger);
    expect(normal.variant, BadgeVariant.success);
    expect(find.text('Stock Bajo'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);

    final low = tester.widget<Text>(find.text('2.5')).style!;
    expect(low.color, AppColors.red600);
    expect(low.fontWeight, FontWeight.w700);
    final ok = tester.widget<Text>(find.text('10')).style!;
    expect(ok.color, AppColors.gray900);
  });

  testWidgets('an empty list shows the empty message', (tester) async {
    when(() => insumos.getInsumos(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const []));
    await pumpTab(tester);

    expect(find.text('No hay insumos registrados'), findsOneWidget);
    expect(find.text('0 insumos registrados'), findsOneWidget);
  });

  testWidgets('a phone shows the insumos as cards', (tester) async {
    await pumpTab(tester, size: TestScreens.phone);

    expect(find.text('Tomate Riñón'), findsOneWidget);
    expect(find.text('Stock Bajo'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a create request opens the new insumo form with defaults', (
    tester,
  ) async {
    await pumpTab(tester);

    await openCreate(tester);

    expect(find.text('Nuevo Insumo'), findsOneWidget);
    expect(
      find.text('Nombre del Insumo *', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Unidad de Medida *', findRichText: true), findsOneWidget);
    expect(
      find.text('Costo Promedio (\$) *', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Stock Actual *', findRichText: true), findsOneWidget);
    expect(find.text('Stock Mínimo *', findRichText: true), findsOneWidget);
    expect(find.text('Ej: Tomate Riñón, Carne de Res, Aceite'), findsOneWidget);
    expect(find.text('UNIDAD (Piezas)'), findsOneWidget);
    expect(find.text('Guardar Insumo'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(fieldText(tester, 'insumo.nombre'), '');
    expect(fieldText(tester, 'insumo.stockActual'), '10');
    expect(fieldText(tester, 'insumo.stockMinimo'), '5');
    expect(fieldText(tester, 'insumo.costo'), '1.00');
  });

  testWidgets('saving a new insumo creates it and closes the form', (
    tester,
  ) async {
    when(() => insumos.createInsumo(any())).thenAnswer((_) async => _aceite);
    await pumpTab(tester);
    await openCreate(tester);

    await tester.enterText(
      find.byKey(const ValueKey('insumo.nombre')),
      ' Aceite de Girasol ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('insumo.stockActual')),
      '2,5',
    );
    await tester.enterText(find.byKey(const ValueKey('insumo.costo')), 'abc');
    await tester.tap(find.text('UNIDAD (Piezas)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LT (Litros)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar Insumo'));
    await tester.pumpAndSettle();

    verify(
      () => insumos.createInsumo(
        const InsumoDraft(
          nombre: 'Aceite de Girasol',
          unidadMedida: UnidadMedida.lt,
          stockActual: 2.5,
          stockMinimo: 5,
          costoPromedio: 0,
        ),
      ),
    ).called(1);
    expect(find.text('Nuevo Insumo'), findsNothing);
  });

  testWidgets('an invalid insumo keeps the form open and notifies', (
    tester,
  ) async {
    await pumpTab(tester);
    await openCreate(tester);

    await tester.enterText(find.byKey(const ValueKey('insumo.nombre')), 'Sal');
    await tester.enterText(
      find.byKey(const ValueKey('insumo.stockMinimo')),
      '-1',
    );
    await tester.tap(find.text('Guardar Insumo'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Insumo'), findsOneWidget);
    expect(find.text('Ingresa un nombre y cantidades válidas'), findsOneWidget);
    verifyNever(() => insumos.createInsumo(any()));
  });

  testWidgets('Editar opens the form prefilled and updates that insumo', (
    tester,
  ) async {
    when(() => insumos.updateInsumo(any(), any()))
        .thenAnswer((_) async => _tomate);
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Editar').first);
    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();

    expect(find.text('Editar Insumo'), findsOneWidget);
    expect(fieldText(tester, 'insumo.nombre'), 'Tomate Riñón');
    expect(fieldText(tester, 'insumo.stockActual'), '2.5');
    expect(fieldText(tester, 'insumo.stockMinimo'), '3');
    expect(fieldText(tester, 'insumo.costo'), '0.85');
    expect(find.text('KG (Kilogramos)'), findsOneWidget);

    await tester.tap(find.text('Guardar Insumo'));
    await tester.pumpAndSettle();

    verify(
      () => insumos.updateInsumo(
        1,
        const InsumoDraft(
          nombre: 'Tomate Riñón',
          unidadMedida: UnidadMedida.kg,
          stockActual: 2.5,
          stockMinimo: 3,
          costoPromedio: 0.85,
        ),
      ),
    ).called(1);
    expect(find.text('Editar Insumo'), findsNothing);
  });

  testWidgets('Eliminar asks for confirmation before deleting', (tester) async {
    when(() => insumos.deleteInsumo(any())).thenAnswer((_) async {});
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar el insumo "Tomate Riñón"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Eliminar'));
    await tester.pumpAndSettle();

    verify(() => insumos.deleteInsumo(1)).called(1);
  });

  testWidgets('cancelling the confirmation keeps the insumo', (tester) async {
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => insumos.deleteInsumo(any()));
  });
}
