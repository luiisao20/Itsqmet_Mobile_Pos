import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/admin_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_metrics.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  for (final tab in [
    AdminTab.platos,
    AdminTab.categorias,
    AdminTab.mesas,
    AdminTab.insumos,
  ]) {
    testWidgets('${tab.name} placeholder shows its label in an EmptyState', (
      tester,
    ) async {
      await tester.pumpApp(adminTabFor(tab, const Stream<void>.empty()));

      final empty = tester.widget<EmptyState>(find.byType(EmptyState));
      expect(empty.title, tab.label);
      expect(empty.icon, tab.icon);
    });
  }

  testWidgets('AdminMetrics placeholder shows the four web metric labels', (
    tester,
  ) async {
    await tester.pumpApp(const AdminMetrics());

    for (final label in ['Platos', 'Mesas', 'Personal', 'Insumos']) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
