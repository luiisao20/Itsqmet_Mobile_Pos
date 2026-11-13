import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/cards/app_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/composite.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

class _Row {
  const _Row(this.id, this.nombre, this.area);

  final int id;
  final String nombre;
  final String area;
}

void main() {
  const rows = [_Row(1, 'Entradas', 'COCINA'), _Row(2, 'Bebidas', 'BAR')];
  final edited = <int>[];

  List<ResponsiveColumn<_Row>> columns() => [
    ResponsiveColumn(label: 'ID', cellBuilder: (_, r) => Text('#${r.id}')),
    ResponsiveColumn(label: 'Nombre', cellBuilder: (_, r) => Text(r.nombre)),
    ResponsiveColumn(
      label: 'Área de Impresión',
      cellBuilder: (_, r) => Text(r.area),
      showOnMobile: false,
    ),
    ResponsiveColumn(
      label: 'Acciones',
      alignEnd: true,
      cellBuilder: (_, r) => TextButton(
        onPressed: () => edited.add(r.id),
        child: Text('Editar ${r.id}'),
      ),
    ),
  ];

  Widget wrap(Widget child) => SingleChildScrollView(child: child);

  setUp(edited.clear);

  testWidgets('tablet renders a DataTable with uppercase headers', (
    tester,
  ) async {
    await tester.pumpApp(
      wrap(ResponsiveDataTable<_Row>(columns: columns(), rows: rows)),
      size: TestScreens.tabletLandscape,
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.byType(AppCard), findsNothing);
    expect(find.text('ID'), findsOneWidget);
    expect(find.text('NOMBRE'), findsOneWidget);
    expect(find.text('ÁREA DE IMPRESIÓN'), findsOneWidget);
    expect(find.text('ACCIONES'), findsOneWidget);
    expect(find.text('Entradas'), findsOneWidget);
    expect(find.text('COCINA'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final table = tester.widget<DataTable>(find.byType(DataTable));
    expect(table.columns.last.numeric, isTrue);
    expect(table.rows, hasLength(2));

    await tester.tap(find.text('Editar 2'));
    expect(edited, [2]);
  });

  testWidgets('tablet portrait also renders the DataTable', (tester) async {
    await tester.pumpApp(
      wrap(ResponsiveDataTable<_Row>(columns: columns(), rows: rows)),
      size: TestScreens.tabletPortrait,
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone renders one card per row with labels and actions', (
    tester,
  ) async {
    await tester.pumpApp(
      wrap(ResponsiveDataTable<_Row>(columns: columns(), rows: rows)),
    );

    expect(find.byType(DataTable), findsNothing);
    expect(find.byType(AppCard), findsNWidgets(2));
    expect(find.text('NOMBRE'), findsNWidgets(2));
    expect(find.text('Entradas'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('ÁREA DE IMPRESIÓN'), findsNothing);
    expect(find.text('COCINA'), findsNothing);
    expect(find.text('ACCIONES'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Editar 1'));
    expect(edited, [1]);
  });

  testWidgets('phone uses mobileCardBuilder when provided', (tester) async {
    await tester.pumpApp(
      wrap(
        ResponsiveDataTable<_Row>(
          columns: columns(),
          rows: rows,
          mobileCardBuilder: (_, r) => Text('Card ${r.nombre}'),
        ),
      ),
    );

    expect(find.text('Card Entradas'), findsOneWidget);
    expect(find.text('Card Bebidas'), findsOneWidget);
    expect(find.text('NOMBRE'), findsNothing);
  });

  for (final entry in {
    'phone': TestScreens.phone,
    'tablet': TestScreens.tabletLandscape,
  }.entries) {
    testWidgets('shows the empty message on ${entry.key}', (tester) async {
      await tester.pumpApp(
        wrap(
          ResponsiveDataTable<_Row>(
            columns: columns(),
            rows: const [],
            emptyMessage: 'No hay categorías registradas',
          ),
        ),
        size: entry.value,
      );

      expect(find.text('No hay categorías registradas'), findsOneWidget);
      expect(find.byType(AppCard), findsNothing);
      expect(find.byType(DataTable), findsNothing);
    });
  }

  testWidgets('default empty message', (tester) async {
    await tester.pumpApp(
      wrap(ResponsiveDataTable<_Row>(columns: columns(), rows: const [])),
    );

    expect(find.text('No hay registros'), findsOneWidget);
  });
}
