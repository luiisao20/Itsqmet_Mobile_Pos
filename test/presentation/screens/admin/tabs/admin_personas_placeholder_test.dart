import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/admin_screen.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  for (final tab in [
    AdminTab.personal,
    AdminTab.clientes,
    AdminTab.distribuidores,
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
}
