import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';

import '../../helpers/pump_app.dart';

void main() {
  Widget mobile(BuildContext _) => const Text('mobile');
  Widget tablet(BuildContext _) => const Text('tablet');

  group('ResponsiveLayout', () {
    testWidgets('shows the mobile builder on a phone', (tester) async {
      await tester.pumpApp(
        ResponsiveLayout(mobile: mobile, tablet: tablet),
        size: const Size(390, 844),
      );

      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('shows the tablet builder on a tablet', (tester) async {
      await tester.pumpApp(
        ResponsiveLayout(mobile: mobile, tablet: tablet),
        size: const Size(1024, 768),
      );

      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });

    testWidgets('falls back to mobile when no tablet builder is given', (
      tester,
    ) async {
      await tester.pumpApp(
        ResponsiveLayout(mobile: mobile),
        size: const Size(800, 1280),
      );

      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('switches when the screen size changes', (tester) async {
      await tester.pumpApp(
        ResponsiveLayout(mobile: mobile, tablet: tablet),
        size: const Size(390, 844),
      );
      expect(find.text('mobile'), findsOneWidget);

      tester.view.physicalSize = const Size(1024, 768);
      await tester.pump();

      expect(find.text('tablet'), findsOneWidget);
    });
  });
}
