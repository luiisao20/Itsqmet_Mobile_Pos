import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/domain/cart/cart.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/composite.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  final ceviche = platoFixture(id: 1, precioUnitario: 8.5, aplicaIva: true);
  final agua = platoFixture(
    id: 2,
    nombre: 'Agua',
    precioUnitario: 1.25,
    aplicaIva: false,
  );
  final items = [
    CartItem(plato: ceviche, cantidad: 2),
    CartItem(plato: agua, cantidad: 4, notasPreparacion: 'fría'),
  ];

  Widget wrap(Widget child) => SingleChildScrollView(child: child);

  testWidgets('empty cart shows the empty message and no submit button', (
    tester,
  ) async {
    await tester.pumpApp(wrap(const OrderSummary(items: [])));

    expect(find.text('Resumen del Pedido'), findsOneWidget);
    expect(find.text('0 items'), findsOneWidget);
    expect(find.text('No hay platos agregados'), findsOneWidget);
    expect(
      find.text('Selecciona platos del menú para armar el pedido'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(find.text('Confirmar Pedido'), findsNothing);
    expect(find.text('Total a Pagar'), findsNothing);
  });

  for (final entry in {
    'phone': TestScreens.phone,
    'tablet': TestScreens.tabletLandscape,
  }.entries) {
    testWidgets('lists items with prices and totals on ${entry.key}', (
      tester,
    ) async {
      await tester.pumpApp(wrap(OrderSummary(items: items)), size: entry.value);

      expect(find.text('2 items'), findsOneWidget);
      expect(find.text('Ceviche'), findsOneWidget);
      expect(find.text('\$8.50 c/u'), findsOneWidget);
      expect(find.text('\$17.00'), findsOneWidget);
      expect(find.text('Agua'), findsOneWidget);
      expect(find.text('\$1.25 c/u'), findsOneWidget);
      expect(find.text('\$5.00'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('\$22.00'), findsOneWidget);
      expect(find.text('IVA (15%)'), findsOneWidget);
      expect(find.text('\$2.55'), findsOneWidget);
      expect(find.text('Total a Pagar'), findsOneWidget);
      expect(find.text('\$24.55'), findsOneWidget);
      expect(find.text('Confirmar Pedido'), findsOneWidget);
      expect(find.text('Observaciones generales del pedido:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('quantity buttons emit index and delta', (tester) async {
    final changes = <(int, int)>[];

    await tester.pumpApp(
      wrap(
        OrderSummary(
          items: items,
          onQuantityChange: (index, delta) => changes.add((index, delta)),
        ),
      ),
    );

    await tester.tap(find.text('+').at(1));
    await tester.tap(find.text('-').first);

    expect(changes, [(1, 1), (0, -1)]);
  });

  testWidgets('Eliminar emits the item index', (tester) async {
    final removed = <int>[];

    await tester.pumpApp(
      wrap(OrderSummary(items: items, onRemoveItem: removed.add)),
    );

    await tester.tap(find.text('Eliminar').last);

    expect(removed, [1]);
  });

  testWidgets('notes field shows current notes and emits changes', (
    tester,
  ) async {
    final notes = <(int, String)>[];

    await tester.pumpApp(
      wrap(
        OrderSummary(
          items: items,
          onNotesChange: (index, value) => notes.add((index, value)),
        ),
      ),
    );

    expect(find.text('fría'), findsOneWidget);
    final field = find.widgetWithText(
      TextField,
      'Instrucción de cocina (ej: sin cebolla, término medio...)',
    );
    expect(field, findsNWidgets(2));

    await tester.enterText(field.first, 'sin sal');

    expect(notes, [(0, 'sin sal')]);
  });

  testWidgets('observaciones field shows the value and emits changes', (
    tester,
  ) async {
    final values = <String>[];

    await tester.pumpApp(
      wrap(
        OrderSummary(
          items: items,
          observaciones: 'Para llevar',
          onObservacionesChange: values.add,
        ),
      ),
    );

    expect(find.text('Para llevar'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Ej: Empacar salsas por separado, cubiertos extras...',
      ),
      'Cubiertos extras',
    );

    expect(values, ['Cubiertos extras']);
  });

  testWidgets('external observaciones updates are reflected', (tester) async {
    await tester.pumpApp(wrap(OrderSummary(items: items, observaciones: 'A')));
    expect(find.text('A'), findsOneWidget);

    await tester.pumpApp(wrap(OrderSummary(items: items)));

    expect(find.text('A'), findsNothing);
  });

  testWidgets('submit button calls onSubmit with custom labels', (
    tester,
  ) async {
    var submitted = 0;

    await tester.pumpApp(
      wrap(
        OrderSummary(
          items: items,
          title: 'Comanda Mesa 4',
          submitLabel: 'Enviar a Cocina',
          onSubmit: () => submitted++,
        ),
      ),
    );

    expect(find.text('Comanda Mesa 4'), findsOneWidget);
    await tester.tap(find.text('Enviar a Cocina'));

    expect(submitted, 1);
  });

  testWidgets('loading shows Procesando... and blocks submit', (tester) async {
    var submitted = 0;

    await tester.pumpApp(
      wrap(
        OrderSummary(items: items, loading: true, onSubmit: () => submitted++),
      ),
    );

    expect(find.text('Procesando...'), findsOneWidget);
    expect(find.text('Confirmar Pedido'), findsNothing);
    await tester.tap(find.text('Procesando...'), warnIfMissed: false);

    expect(submitted, 0);
  });

  testWidgets('removing an item keeps the remaining notes aligned', (
    tester,
  ) async {
    await tester.pumpApp(wrap(OrderSummary(items: items)));
    await tester.pumpApp(wrap(OrderSummary(items: [items[1]])));

    expect(find.text('fría'), findsOneWidget);
    expect(find.text('Ceviche'), findsNothing);
    expect(find.text('1 items'), findsOneWidget);
  });
}
