import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/layout.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const childKey = Key('child');
  const child = SizedBox(key: childKey, width: double.infinity, height: 50);

  group('PageContainer', () {
    testWidgets('applies 16px horizontal padding on a phone', (tester) async {
      await tester.pumpApp(const PageContainer(child: child));

      expect(tester.getSize(find.byKey(childKey)).width, 390 - 32);
      expect(tester.getTopLeft(find.byKey(childKey)).dx, 16);
      expect(tester.getTopLeft(find.byKey(childKey)).dy, 32);
    });

    testWidgets('applies 24px horizontal padding at sm', (tester) async {
      await tester.pumpApp(
        const PageContainer(child: child),
        size: TestScreens.tabletPortrait,
      );

      expect(tester.getSize(find.byKey(childKey)).width, 800 - 48);
    });

    testWidgets('caps the width at 1280 and centers on wide screens', (
      tester,
    ) async {
      await tester.pumpApp(
        const PageContainer(child: child),
        size: const Size(1600, 900),
      );

      expect(tester.getSize(find.byKey(childKey)).width, 1280 - 64);
      expect(tester.getCenter(find.byKey(childKey)).dx, 800);
    });

    testWidgets('renders the footer after the content by default', (
      tester,
    ) async {
      await tester.pumpApp(const PageContainer(child: child));

      expect(find.byType(AppFooter), findsOneWidget);
    });

    testWidgets('sticks the footer to the bottom when content is short', (
      tester,
    ) async {
      await tester.pumpApp(const PageContainer(child: child));

      expect(tester.getBottomLeft(find.byType(AppFooter)).dy, 844);
    });

    testWidgets('scrolls to the footer when content is long', (tester) async {
      await tester.pumpApp(const PageContainer(child: SizedBox(height: 2000)));

      expect(find.byType(AppFooter), findsNothing);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
      await tester.pump();

      expect(
        tester.getBottomLeft(find.byType(AppFooter)).dy,
        closeTo(844, 0.01),
      );
    });

    testWidgets('showFooter: false hides the footer', (tester) async {
      await tester.pumpApp(
        const PageContainer(showFooter: false, child: child),
      );

      expect(find.byType(AppFooter), findsNothing);
    });

    testWidgets('scrollable: false gives the child the bounded height', (
      tester,
    ) async {
      await tester.pumpApp(
        const PageContainer(
          scrollable: false,
          child: Column(
            children: [
              Expanded(
                child: SizedBox(key: childKey, width: double.infinity),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(AppFooter), findsNothing);
      expect(find.byType(CustomScrollView), findsNothing);
      expect(tester.getSize(find.byKey(childKey)).height, 844 - 64);
    });
  });
}
