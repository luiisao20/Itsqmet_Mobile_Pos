import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/composite.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const items = [
    PillItem<int?>(value: null, label: 'Todos los Platos'),
    PillItem<int?>(value: 1, label: 'Entradas'),
    PillItem<int?>(value: 2, label: 'Fuertes', icon: Icons.restaurant),
  ];

  Container pillContainer(WidgetTester tester, String label) {
    return tester.widget<Container>(
      find
          .ancestor(of: find.text(label), matching: find.byType(Container))
          .first,
    );
  }

  BoxDecoration pillDecoration(WidgetTester tester, String label) =>
      pillContainer(tester, label).decoration! as BoxDecoration;

  for (final entry in {
    'phone': TestScreens.phone,
    'tablet': TestScreens.tabletLandscape,
  }.entries) {
    testWidgets('renders pills and emits the tapped value on ${entry.key}', (
      tester,
    ) async {
      final selected = <int?>[];

      await tester.pumpApp(
        PillSelector<int?>(items: items, selected: 1, onSelected: selected.add),
        size: entry.value,
      );

      expect(find.text('Todos los Platos'), findsOneWidget);
      expect(find.text('Entradas'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Todos los Platos'));
      await tester.ensureVisible(find.text('Fuertes'));
      await tester.tap(find.text('Fuertes'));

      expect(selected, [null, 2]);
    });
  }

  testWidgets('scrolls horizontally', (tester) async {
    await tester.pumpApp(
      PillSelector<int?>(items: items, selected: null, onSelected: (_) {}),
    );

    final scroll = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scroll.scrollDirection, Axis.horizontal);
  });

  testWidgets('filled style: active emerald-600, inactive gray-100', (
    tester,
  ) async {
    await tester.pumpApp(
      PillSelector<int?>(items: items, selected: null, onSelected: (_) {}),
    );

    expect(
      pillDecoration(tester, 'Todos los Platos').color,
      AppColors.emerald600,
    );
    expect(
      tester.widget<Text>(find.text('Todos los Platos')).style!.color,
      AppColors.white,
    );
    expect(pillDecoration(tester, 'Entradas').color, AppColors.gray100);
    final inactive = tester.widget<Text>(find.text('Entradas'));
    expect(inactive.style!.color, AppColors.gray600);
    expect(inactive.style!.fontWeight, FontWeight.w600);
    expect(inactive.style!.fontSize, 12);
    expect(
      pillContainer(tester, 'Entradas').padding,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  });

  testWidgets('outlined style: inactive white with gray-200 border', (
    tester,
  ) async {
    await tester.pumpApp(
      PillSelector<int?>(
        items: items,
        selected: null,
        onSelected: (_) {},
        style: PillSelectorStyle.outlined,
      ),
    );

    final decoration = pillDecoration(tester, 'Entradas');
    expect(decoration.color, AppColors.white);
    expect((decoration.border! as Border).top.color, AppColors.gray200);
    expect(
      tester.widget<Text>(find.text('Entradas')).style!.color,
      AppColors.gray700,
    );
  });

  testWidgets('md size uses bold text and larger padding', (tester) async {
    await tester.pumpApp(
      PillSelector<String>(
        items: const [PillItem(value: 'platos', label: 'Platos (3)')],
        selected: 'platos',
        onSelected: (_) {},
        size: PillSize.md,
      ),
    );

    expect(
      tester.widget<Text>(find.text('Platos (3)')).style!.fontWeight,
      FontWeight.w700,
    );
    expect(
      pillContainer(tester, 'Platos (3)').padding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  });
}
