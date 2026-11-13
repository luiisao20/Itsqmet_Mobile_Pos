import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/shared/feature_placeholder.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'pump_app.dart';

void testFeaturePlaceholder(
  String name,
  Widget Function() screen, {
  required String title,
  required String subtitle,
  required IconData icon,
}) {
  for (final size in [TestScreens.phone, TestScreens.tabletLandscape]) {
    testWidgets('$name shows its web title inside a placeholder at $size', (
      tester,
    ) async {
      await tester.pumpApp(screen(), size: size);

      expect(tester.takeException(), isNull);
      expect(find.byType(FeaturePlaceholder), findsOneWidget);
      expect(find.byType(PageContainer), findsOneWidget);
      final header = tester.widget<PageHeader>(find.byType(PageHeader));
      expect(header.title, title);
      expect(header.subtitle, subtitle);
      expect(header.icon, icon);
      expect(find.text(FeaturePlaceholder.emptyTitle), findsOneWidget);
      expect(find.text(FeaturePlaceholder.emptyMessage), findsOneWidget);
    });
  }
}
