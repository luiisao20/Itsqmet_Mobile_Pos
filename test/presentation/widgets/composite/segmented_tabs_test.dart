import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/composite.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const items = [
    SegmentedTabItem(
      value: 'nuevo',
      label: 'Nuevo Pedido (Llevar)',
      icon: Icons.shopping_bag_outlined,
    ),
    SegmentedTabItem(
      value: 'historial',
      label: 'Mis Pedidos',
      icon: Icons.receipt_long_outlined,
      badgeCount: 3,
    ),
    SegmentedTabItem(value: 'facturas', label: 'Mis Facturas'),
  ];

  BoxDecoration decorationAround(WidgetTester tester, String label) {
    final container = tester.widget<Container>(
      find
          .ancestor(of: find.text(label), matching: find.byType(Container))
          .first,
    );
    return container.decoration! as BoxDecoration;
  }

  BoxDecoration outerDecoration(WidgetTester tester) {
    final outer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(SegmentedTabs<String>),
            matching: find.byType(Container),
          )
          .first,
    );
    return outer.decoration! as BoxDecoration;
  }

  for (final entry in {
    'phone': TestScreens.phone,
    'tablet': TestScreens.tabletLandscape,
  }.entries) {
    testWidgets('renders tabs and emits the tapped value on ${entry.key}', (
      tester,
    ) async {
      final changes = <String>[];

      await tester.pumpApp(
        SegmentedTabs<String>(
          items: items,
          selected: 'nuevo',
          onChanged: changes.add,
        ),
        size: entry.value,
      );

      expect(find.text('Nuevo Pedido (Llevar)'), findsOneWidget);
      expect(find.text('Mis Pedidos'), findsOneWidget);
      expect(find.text('Mis Facturas'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Mis Facturas'));
      await tester.tap(find.text('Mis Facturas'));

      expect(changes, ['facturas']);
    });
  }

  testWidgets('active tab is emerald-600 with white bold text', (tester) async {
    await tester.pumpApp(
      SegmentedTabs<String>(items: items, selected: 'nuevo', onChanged: (_) {}),
    );

    expect(
      decorationAround(tester, 'Nuevo Pedido (Llevar)').color,
      AppColors.emerald600,
    );
    final active = tester.widget<Text>(find.text('Nuevo Pedido (Llevar)'));
    expect(active.style!.color, AppColors.white);
    expect(active.style!.fontWeight, FontWeight.w700);
    expect(active.style!.fontSize, 12);

    final inactive = tester.widget<Text>(find.text('Mis Facturas'));
    expect(inactive.style!.color, AppColors.gray600);
    expect(
      decorationAround(tester, 'Mis Facturas').color,
      isNot(AppColors.emerald600),
    );
  });

  testWidgets('badge is emerald-100 when inactive and white when active', (
    tester,
  ) async {
    await tester.pumpApp(
      SegmentedTabs<String>(items: items, selected: 'nuevo', onChanged: (_) {}),
    );

    expect(find.text('3'), findsOneWidget);
    expect(decorationAround(tester, '3').color, AppColors.emerald100);
    expect(
      tester.widget<Text>(find.text('3')).style!.color,
      AppColors.emerald800,
    );

    await tester.pumpApp(
      SegmentedTabs<String>(
        items: items,
        selected: 'historial',
        onChanged: (_) {},
      ),
    );

    expect(decorationAround(tester, '3').color, AppColors.white);
    expect(
      tester.widget<Text>(find.text('3')).style!.color,
      AppColors.emerald700,
    );
  });

  testWidgets('badge is hidden when the count is zero', (tester) async {
    await tester.pumpApp(
      SegmentedTabs<String>(
        items: const [SegmentedTabItem(value: 'a', label: 'A', badgeCount: 0)],
        selected: 'a',
        onChanged: (_) {},
      ),
    );

    expect(find.text('0'), findsNothing);
  });

  testWidgets('custom active color and border color are used', (tester) async {
    await tester.pumpApp(
      SegmentedTabs<String>(
        items: const [
          SegmentedTabItem(value: 'TODOS', label: 'Todos (4)'),
          SegmentedTabItem(
            value: 'ABIERTO',
            label: 'Nuevos',
            activeColor: AppColors.sky600,
          ),
        ],
        selected: 'ABIERTO',
        onChanged: (_) {},
        compact: true,
        borderColor: AppColors.gray200,
      ),
    );

    expect(decorationAround(tester, 'Nuevos').color, AppColors.sky600);
    final container = tester.widget<Container>(
      find
          .ancestor(of: find.text('Nuevos'), matching: find.byType(Container))
          .first,
    );
    expect(
      container.padding,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
    expect(
      (outerDecoration(tester).border! as Border).top.color,
      AppColors.gray200,
    );
  });

  testWidgets('container defaults to white, emerald-100 border, radius 16', (
    tester,
  ) async {
    await tester.pumpApp(
      SegmentedTabs<String>(items: items, selected: 'nuevo', onChanged: (_) {}),
    );

    final decoration = outerDecoration(tester);
    expect(decoration.color, AppColors.white);
    expect((decoration.border! as Border).top.color, AppColors.emerald100);
    expect(decoration.borderRadius, AppRadius.lgAll);
    final tab = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Mis Facturas'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      tab.padding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  });
}
