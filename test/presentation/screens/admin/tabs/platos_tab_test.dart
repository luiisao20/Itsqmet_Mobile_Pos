import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/platos_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockCatalogo extends Mock implements CatalogoRepository {}

Plato _plato(
  int id, {
  String? descripcion = 'Con arroz',
  bool disponible = true,
  bool aplicaIva = true,
  String? categoria = 'Platos Fuertes',
}) => Plato(
  id: id,
  idCategoria: 3,
  nombreCategoria: categoria,
  nombre: 'Seco $id',
  descripcion: descripcion,
  precioUnitario: 8.5,
  aplicaIva: aplicaIva,
  disponible: disponible,
);

const _fuertes = CategoriaPlato(
  id: 3,
  nombre: 'Platos Fuertes',
  areaImpresion: AreaImpresion.cocina,
);

const _bebidas = CategoriaPlato(
  id: 7,
  nombre: 'Bebidas',
  areaImpresion: AreaImpresion.bar,
);

void main() {
  late _MockCatalogo catalogo;
  late PlatosCubit cubit;
  late StreamController<void> createRequests;

  setUpAll(() {
    registerFallbackValue(
      const PlatoDraft(
        idCategoria: 0,
        nombre: '',
        precioUnitario: 0,
        aplicaIva: true,
        disponible: true,
      ),
    );
  });

  setUp(() {
    catalogo = _MockCatalogo();
    createRequests = StreamController<void>.broadcast();
    when(() => catalogo.getPlatos(page: 0, size: 100)).thenAnswer(
      (_) async => PageResult.single([
        _plato(1),
        _plato(
          2,
          descripcion: null,
          disponible: false,
          aplicaIva: false,
          categoria: null,
        ),
      ]),
    );
    when(() => catalogo.getCategorias())
        .thenAnswer((_) async => [_fuertes, _bebidas]);
    cubit = PlatosCubit(catalogoRepository: catalogo, changes: AdminChanges());
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
            child: BlocProvider<PlatosCubit>.value(
              value: cubit,
              child: PlatosView(createRequests: createRequests.stream),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the table shows every column of each plato', (tester) async {
    await pumpTab(tester);

    expect(find.text('Catálogo de Platos del Menú'), findsOneWidget);
    expect(find.text('2 registrados'), findsOneWidget);
    for (final header in ['PLATO', 'CATEGORÍA', 'PRECIO', 'IVA', 'ESTADO']) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('Seco 1'), findsOneWidget);
    expect(find.text('Con arroz'), findsOneWidget);
    expect(find.text('Sin descripción'), findsOneWidget);
    expect(find.text('Platos Fuertes'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('\$8.50'), findsNWidgets(2));
    expect(find.text('15%'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Disponible'), findsOneWidget);
    expect(find.text('Agotado'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Eliminar'), findsNWidgets(2));
  });

  testWidgets('an empty list shows the empty message', (tester) async {
    when(() => catalogo.getPlatos(page: 0, size: 100))
        .thenAnswer((_) async => PageResult.single(const []));
    await pumpTab(tester);

    expect(find.text('No hay platos registrados'), findsOneWidget);
    expect(find.text('0 registrados'), findsOneWidget);
  });

  testWidgets('a phone shows the platos as cards', (tester) async {
    await pumpTab(tester, size: TestScreens.phone);

    expect(find.text('Seco 1'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a create request opens the new plato form with defaults', (
    tester,
  ) async {
    await pumpTab(tester);

    createRequests.add(null);
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Plato'), findsOneWidget);
    expect(find.text('Nombre del Plato *', findRichText: true), findsOneWidget);
    expect(find.text('Categoría *', findRichText: true), findsOneWidget);
    expect(find.text('Precio (\$) *', findRichText: true), findsOneWidget);
    expect(find.text('Descripción'), findsOneWidget);
    expect(find.text('URL Imagen'), findsOneWidget);
    expect(find.text('Aplica IVA (15%)'), findsOneWidget);
    expect(find.text('Disponible en Menú'), findsOneWidget);
    expect(find.text('Guardar Plato'), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
  });

  testWidgets('saving a new plato creates it and closes the form', (
    tester,
  ) async {
    when(() => catalogo.createPlato(any())).thenAnswer((_) async => _plato(9));
    await pumpTab(tester);
    createRequests.add(null);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('plato.nombre')),
      ' Seco de Chivo ',
    );
    await tester.enterText(find.byKey(const ValueKey('plato.precio')), '9.75');
    await tester.tap(find.text('Aplica IVA (15%)'));
    await tester.tap(find.text('Guardar Plato'));
    await tester.pumpAndSettle();

    verify(
      () => catalogo.createPlato(
        const PlatoDraft(
          idCategoria: 3,
          nombre: 'Seco de Chivo',
          precioUnitario: 9.75,
          aplicaIva: false,
          disponible: true,
        ),
      ),
    ).called(1);
    expect(find.text('Nuevo Plato'), findsNothing);
  });

  testWidgets('an invalid plato keeps the form open and notifies', (
    tester,
  ) async {
    await pumpTab(tester);
    createRequests.add(null);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Plato'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Plato'), findsOneWidget);
    expect(find.text('Ingresa un nombre y precio válido'), findsOneWidget);
    verifyNever(() => catalogo.createPlato(any()));
  });

  testWidgets('Editar opens the form prefilled and updates that plato', (
    tester,
  ) async {
    when(() => catalogo.updatePlato(any(), any()))
        .thenAnswer((_) async => _plato(1));
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Editar').first);
    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();

    expect(find.text('Editar Plato'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const ValueKey('plato.nombre')),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      'Seco 1',
    );

    await tester.tap(find.text('Guardar Plato'));
    await tester.pumpAndSettle();

    verify(() => catalogo.updatePlato(1, any())).called(1);
  });

  testWidgets('Eliminar asks for confirmation before deleting', (tester) async {
    when(() => catalogo.deletePlato(any())).thenAnswer((_) async {});
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar el plato "Seco 1"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Eliminar'));
    await tester.pumpAndSettle();

    verify(() => catalogo.deletePlato(1)).called(1);
  });

  testWidgets('cancelling the confirmation keeps the plato', (tester) async {
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => catalogo.deletePlato(any()));
  });

  testWidgets('tapping the availability badge toggles it', (tester) async {
    when(() => catalogo.updatePlato(any(), any()))
        .thenAnswer((_) async => _plato(2, disponible: true));
    await pumpTab(tester);

    await tester.tap(find.text('Agotado'));
    await tester.pumpAndSettle();

    final draft =
        verify(() => catalogo.updatePlato(2, captureAny())).captured.single
            as PlatoDraft;
    expect(draft.disponible, isTrue);
  });
}
