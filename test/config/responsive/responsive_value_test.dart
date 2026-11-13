import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('responsiveValueFor', () {
    test('returns base when no breakpoint matches', () {
      expect(responsiveValueFor<int>(390, base: 1, sm: 2, md: 3), 1);
    });

    test('picks the largest matching breakpoint (mobile-first)', () {
      const values = (base: 1, sm: 2, md: 3, lg: 4, xl: 5);

      int pick(double width) => responsiveValueFor<int>(
        width,
        base: values.base,
        sm: values.sm,
        md: values.md,
        lg: values.lg,
        xl: values.xl,
      );

      expect(pick(639), 1);
      expect(pick(640), 2);
      expect(pick(767), 2);
      expect(pick(768), 3);
      expect(pick(1024), 4);
      expect(pick(1280), 5);
    });

    test('skips breakpoints that are not provided', () {
      expect(responsiveValueFor<int>(1100, base: 1, md: 3), 3);
      expect(responsiveValueFor<int>(1500, base: 1, md: 3), 3);
      expect(responsiveValueFor<int>(700, base: 1, md: 3), 1);
    });

    test('supports the dishes grid column counts 1/2/3/4', () {
      int columns(double width) =>
          responsiveValueFor<int>(width, base: 1, sm: 2, lg: 3, xl: 4);

      expect(columns(390), 1);
      expect(columns(800), 2);
      expect(columns(1024), 3);
      expect(columns(1280), 4);
    });
  });

  group('ResponsiveValue', () {
    test('resolve uses the same rules as responsiveValueFor', () {
      const value = ResponsiveValue<int>(base: 2, md: 3, lg: 4);

      expect(value.resolve(390), 2);
      expect(value.resolve(800), 3);
      expect(value.resolve(1100), 4);
    });
  });

  group('responsive(context)', () {
    testWidgets('resolves with the current screen width', (tester) async {
      int? phone;
      int? tablet;

      await tester.pumpApp(
        Builder(
          builder: (context) {
            phone = responsive<int>(context, base: 2, md: 4);
            return const SizedBox();
          },
        ),
        size: const Size(390, 844),
      );
      await tester.pumpApp(
        Builder(
          builder: (context) {
            tablet = responsive<int>(context, base: 2, md: 4);
            return const SizedBox();
          },
        ),
        size: const Size(1024, 768),
      );

      expect(phone, 2);
      expect(tablet, 4);
    });
  });
}
