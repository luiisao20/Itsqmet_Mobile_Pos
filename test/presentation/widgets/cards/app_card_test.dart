import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  BoxDecoration decorationOf(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppCard),
        matching: find.byType(Container),
      ),
    );
    return container.decoration! as BoxDecoration;
  }

  testWidgets('uses white surface, emerald-100 border, radius 16, shadow xs', (
    tester,
  ) async {
    await tester.pumpApp(const AppCard(child: Text('Contenido')));

    final decoration = decorationOf(tester);

    expect(find.text('Contenido'), findsOneWidget);
    expect(decoration.color, AppColors.white);
    expect(decoration.borderRadius, AppRadius.lgAll);
    expect((decoration.border! as Border).top.color, AppColors.emerald100);
    expect(decoration.boxShadow, AppShadows.xs);
  });

  testWidgets('large uses radius 24', (tester) async {
    await tester.pumpApp(const AppCard(large: true, child: Text('Grande')));

    expect(decorationOf(tester).borderRadius, AppRadius.xlAll);
  });

  testWidgets('default padding is 16', (tester) async {
    await tester.pumpApp(
      const Align(
        alignment: Alignment.topLeft,
        child: AppCard(child: SizedBox(width: 50, height: 20)),
      ),
    );

    expect(tester.getSize(find.byType(AppCard)), const Size(84, 54));
  });

  testWidgets('onTap makes the card tappable', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      AppCard(onTap: () => taps++, child: const Text('Tocar')),
    );

    await tester.tap(find.text('Tocar'));

    expect(taps, 1);
  });
}
