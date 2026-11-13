import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<BuildContext> contextFor(WidgetTester tester, Size size) async {
    late BuildContext captured;
    await tester.pumpApp(
      Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
      size: size,
    );
    return captured;
  }

  group('ResponsiveContext', () {
    testWidgets('phone portrait (390x844) is mobile', (tester) async {
      final context = await contextFor(tester, const Size(390, 844));

      expect(context.deviceType, DeviceType.mobile);
      expect(context.isMobile, isTrue);
      expect(context.isTablet, isFalse);
      expect(context.screenWidth, 390);
      expect(context.isLandscape, isFalse);
      expect(context.atLeastSm, isFalse);
      expect(context.pagePadding, 16);
    });

    testWidgets('phone landscape (844x390) is still mobile', (tester) async {
      final context = await contextFor(tester, const Size(844, 390));

      expect(context.isMobile, isTrue);
      expect(context.isLandscape, isTrue);
      expect(context.atLeastSm, isTrue);
      expect(context.atLeastMd, isTrue);
      expect(context.atLeastLg, isFalse);
      expect(context.pagePadding, 24);
    });

    testWidgets('tablet landscape (1024x768) is tablet', (tester) async {
      final context = await contextFor(tester, const Size(1024, 768));

      expect(context.deviceType, DeviceType.tablet);
      expect(context.isTablet, isTrue);
      expect(context.isLandscape, isTrue);
      expect(context.atLeastLg, isTrue);
      expect(context.atLeastXl, isFalse);
      expect(context.pagePadding, 32);
    });

    testWidgets('tablet portrait (800x1280) is tablet', (tester) async {
      final context = await contextFor(tester, const Size(800, 1280));

      expect(context.isTablet, isTrue);
      expect(context.isLandscape, isFalse);
      expect(context.atLeastMd, isTrue);
      expect(context.atLeastLg, isFalse);
      expect(context.pagePadding, 24);
    });
  });
}
