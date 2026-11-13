import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/tabs/categorias_tab.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_catalogo.dart';
import 'package:itsqmet_mobile_pos/services/notifications_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockCatalogo extends Mock implements CatalogoRepository {}

const _fuertes = CategoriaPlato(
  id: 3,
  nombre: 'Platos Fuertes',
  areaImpresion: AreaImpresion.cocina,
  ordenVisual: 2,
);

const _bebidas = CategoriaPlato(
  id: 7,
  nombre: 'Bebidas',
  areaImpresion: AreaImpresion.bar,
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
  late _MockCatalogo catalogo;
  late CategoriasCubit cubit;
  late StreamController<void> createRequests;

  setUpAll(() {
    registerFallbackValue(
      const CategoriaPlatoDraft(
        nombre: '',
        areaImpresion: AreaImpresion.cocina,
      ),
    );
  });

  setUp(() {
    catalogo = _MockCatalogo();
    createRequests = StreamController<void>.broadcast();
    when(() => catalogo.getCategorias())
        .thenAnswer((_) async => [_fuertes, _bebidas]);
    cubit = CategoriasCubit(
      catalogoRepository: catalogo,
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
            child: BlocProvider<CategoriasCubit>.value(
              value: cubit,
              child: CategoriasView(createRequests: createRequests.stream),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the table shows every column of each categoria', (tester) async {
    await pumpTab(tester);

    expect(find.text('Categorías del Menú'), findsOneWidget);
    expect(find.text('2 registradas'), findsOneWidget);
    for (final header in [
      'ID',
      'NOMBRE',
      'ÁREA DE IMPRESIÓN',
      'ORDEN VISUAL',
      'ACCIONES',
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text('#3'), findsOneWidget);
    expect(find.text('#7'), findsOneWidget);
    expect(find.text('Platos Fuertes'), findsOneWidget);
    expect(find.text('Bebidas'), findsOneWidget);
    expect(find.text('COCINA'), findsOneWidget);
    expect(find.text('BAR'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(find.text('Eliminar'), findsNWidgets(2));
  });

  testWidgets('the area chip is amber for COCINA and blue otherwise', (
    tester,
  ) async {
    await pumpTab(tester);

    expect(
      tester.widget<Text>(find.text('COCINA')).style!.color,
      AppColors.amber800,
    );
    expect(
      tester.widget<Text>(find.text('BAR')).style!.color,
      AppColors.blue800,
    );
    BoxDecoration chipOf(String label) =>
        tester
                .widget<Container>(
                  find
                      .ancestor(
                        of: find.text(label),
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration;
    expect(chipOf('COCINA').color, AppColors.amber100);
    expect(chipOf('BAR').color, AppColors.blue100);
  });

  testWidgets('an empty list shows the empty message', (tester) async {
    when(() => catalogo.getCategorias()).thenAnswer((_) async => const []);
    await pumpTab(tester);

    expect(find.text('No hay categorías registradas'), findsOneWidget);
    expect(find.text('0 registradas'), findsOneWidget);
  });

  testWidgets('a phone shows the categorias as cards', (tester) async {
    await pumpTab(tester, size: TestScreens.phone);

    expect(find.text('Platos Fuertes'), findsOneWidget);
    expect(find.text('Bebidas'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a create request opens the new categoria form with defaults', (
    tester,
  ) async {
    await pumpTab(tester);

    createRequests.add(null);
    await tester.pumpAndSettle();

    expect(find.text('Nueva Categoría'), findsOneWidget);
    expect(
      find.text('Nombre de la Categoría *', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Ej: Platos Fuertes, Bebidas, Postres'), findsOneWidget);
    expect(
      find.text('Área de Impresión *', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Orden Visual'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Guardar Categoría'), findsOneWidget);
    expect(_fieldText(tester, 'categoria.nombre'), '');
    expect(_fieldText(tester, 'categoria.orden'), '3');
    expect(find.text('COCINA'), findsNWidgets(2));
  });

  testWidgets('the area dropdown offers COCINA, BAR and CAJA', (tester) async {
    await pumpTab(tester);
    createRequests.add(null);
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('categoria.area')),
        matching: find.byType(DropdownButton<AreaImpresion>),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CAJA'), findsWidgets);
    await tester.tap(find.text('CAJA').last);
    await tester.pumpAndSettle();
    when(() => catalogo.createCategoria(any()))
        .thenAnswer((_) async => _bebidas);
    await tester.enterText(
      find.byKey(const ValueKey('categoria.nombre')),
      'Postres',
    );
    await tester.tap(find.text('Guardar Categoría'));
    await tester.pumpAndSettle();

    verify(
      () => catalogo.createCategoria(
        const CategoriaPlatoDraft(
          nombre: 'Postres',
          areaImpresion: AreaImpresion.caja,
          ordenVisual: 3,
        ),
      ),
    ).called(1);
  });

  testWidgets('saving a new categoria creates it and closes the form', (
    tester,
  ) async {
    when(() => catalogo.createCategoria(any()))
        .thenAnswer((_) async => _bebidas);
    await pumpTab(tester);
    createRequests.add(null);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('categoria.nombre')),
      ' Postres ',
    );
    await tester.enterText(find.byKey(const ValueKey('categoria.orden')), '');
    await tester.tap(find.text('Guardar Categoría'));
    await tester.pumpAndSettle();

    verify(
      () => catalogo.createCategoria(
        const CategoriaPlatoDraft(
          nombre: 'Postres',
          areaImpresion: AreaImpresion.cocina,
          ordenVisual: 0,
        ),
      ),
    ).called(1);
    expect(find.text('Nueva Categoría'), findsNothing);
  });

  testWidgets('an invalid categoria keeps the form open and notifies', (
    tester,
  ) async {
    await pumpTab(tester);
    createRequests.add(null);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar Categoría'));
    await tester.pumpAndSettle();

    expect(find.text('Nueva Categoría'), findsOneWidget);
    expect(find.text('Ingresa el nombre de la categoría'), findsOneWidget);
    verifyNever(() => catalogo.createCategoria(any()));
  });

  testWidgets('Editar opens the form prefilled and updates that categoria', (
    tester,
  ) async {
    when(() => catalogo.updateCategoria(any(), any()))
        .thenAnswer((_) async => _bebidas);
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Editar').last);
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    expect(find.text('Editar Categoría'), findsOneWidget);
    expect(_fieldText(tester, 'categoria.nombre'), 'Bebidas');
    expect(_fieldText(tester, 'categoria.orden'), '1');

    await tester.tap(find.text('Guardar Categoría'));
    await tester.pumpAndSettle();

    verify(
      () => catalogo.updateCategoria(
        7,
        const CategoriaPlatoDraft(
          nombre: 'Bebidas',
          areaImpresion: AreaImpresion.bar,
          ordenVisual: 1,
        ),
      ),
    ).called(1);
    expect(find.text('Editar Categoría'), findsNothing);
  });

  testWidgets('Eliminar asks for confirmation before deleting', (tester) async {
    when(() => catalogo.deleteCategoria(any())).thenAnswer((_) async {});
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();

    expect(
      find.text('¿Eliminar la categoría "Platos Fuertes"?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(AppButton, 'Eliminar'));
    await tester.pumpAndSettle();

    verify(() => catalogo.deleteCategoria(3)).called(1);
  });

  testWidgets('cancelling the confirmation keeps the categoria', (
    tester,
  ) async {
    await pumpTab(tester);

    await tester.ensureVisible(find.text('Eliminar').first);
    await tester.tap(find.text('Eliminar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => catalogo.deleteCategoria(any()));
  });
}
