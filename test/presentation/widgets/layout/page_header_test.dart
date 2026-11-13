import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Widget header() => PageHeader(
    icon: Icons.restaurant,
    title: 'Mesas',
    subtitle: 'Gestión de mesas',
    actions: [AppButton(label: 'Nueva', onPressed: () {})],
  );

  group('PageHeader', () {
    testWidgets('renders title, subtitle and emoji box', (tester) async {
      await tester.pumpApp(header());

      final title = tester.widget<Text>(find.text('Mesas'));
      final subtitle = tester.widget<Text>(find.text('Gestión de mesas'));

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(title.style!.fontSize, 24);
      expect(title.style!.fontWeight, FontWeight.w900);
      expect(title.style!.color, AppColors.emerald950);
      expect(subtitle.style!.fontSize, 12);
      expect(subtitle.style!.color, AppColors.gray500);
    });

    testWidgets('stacks the actions under the title on a phone', (
      tester,
    ) async {
      await tester.pumpApp(header(), size: TestScreens.phone);

      final titleBottom = tester.getBottomLeft(find.text('Mesas')).dy;
      final actionTop = tester.getTopLeft(find.byType(AppButton)).dy;
      final actionLeft = tester.getTopLeft(find.byType(AppButton)).dx;

      expect(actionTop, greaterThan(titleBottom));
      expect(actionLeft, lessThan(100));
    });

    testWidgets('places the actions on the same row on a tablet', (
      tester,
    ) async {
      await tester.pumpApp(
        Align(alignment: Alignment.topLeft, child: header()),
        size: TestScreens.tabletLandscape,
      );

      final titleBox = tester.getRect(find.text('Mesas'));
      final actionBox = tester.getRect(find.byType(AppButton));

      expect(actionBox.left, greaterThan(titleBox.right));
      expect(actionBox.center.dy, lessThan(titleBox.bottom + 40));
      expect(actionBox.top, lessThan(titleBox.bottom));
    });

    testWidgets('draws the emerald-100 bottom border', (tester) async {
      await tester.pumpApp(header());

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PageHeader),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;

      expect((decoration.border! as Border).bottom.color, AppColors.emerald100);
    });
  });
}
