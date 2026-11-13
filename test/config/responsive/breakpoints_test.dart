import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/responsive/breakpoints.dart';

void main() {
  group('Breakpoints', () {
    test('match the Tailwind defaults plus the tablet threshold', () {
      expect(Breakpoints.sm, 640);
      expect(Breakpoints.md, 768);
      expect(Breakpoints.lg, 1024);
      expect(Breakpoints.xl, 1280);
      expect(Breakpoints.tablet, 600);
    });
  });

  group('Breakpoints.deviceTypeFor', () {
    test('classifies phones as mobile', () {
      expect(Breakpoints.deviceTypeFor(390), DeviceType.mobile);
      expect(Breakpoints.deviceTypeFor(599.9), DeviceType.mobile);
    });

    test('classifies the shortest side threshold as tablet', () {
      expect(Breakpoints.deviceTypeFor(600), DeviceType.tablet);
      expect(Breakpoints.deviceTypeFor(768), DeviceType.tablet);
      expect(Breakpoints.deviceTypeFor(1024), DeviceType.tablet);
    });
  });

  group('ScreenSize', () {
    test('uses mobile-first (min-width) semantics', () {
      expect(ScreenSize.isSm(639.9), isFalse);
      expect(ScreenSize.isSm(640), isTrue);
      expect(ScreenSize.isMd(767), isFalse);
      expect(ScreenSize.isMd(768), isTrue);
      expect(ScreenSize.isLg(1023), isFalse);
      expect(ScreenSize.isLg(1024), isTrue);
      expect(ScreenSize.isXl(1279), isFalse);
      expect(ScreenSize.isXl(1280), isTrue);
    });

    test('pagePaddingFor mirrors px-4 sm:px-6 lg:px-8', () {
      expect(ScreenSize.pagePaddingFor(390), 16);
      expect(ScreenSize.pagePaddingFor(639), 16);
      expect(ScreenSize.pagePaddingFor(640), 24);
      expect(ScreenSize.pagePaddingFor(1023), 24);
      expect(ScreenSize.pagePaddingFor(1024), 32);
      expect(ScreenSize.pagePaddingFor(1600), 32);
    });
  });
}
