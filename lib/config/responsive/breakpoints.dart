import 'package:itsqmet_mobile_pos/config/theme/app_spacing.dart';

enum DeviceType { mobile, tablet }

abstract final class Breakpoints {
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;

  static const double tablet = 600;

  static DeviceType deviceTypeFor(double shortestSide) =>
      shortestSide >= tablet ? DeviceType.tablet : DeviceType.mobile;
}

abstract final class ScreenSize {
  static bool isSm(double width) => width >= Breakpoints.sm;
  static bool isMd(double width) => width >= Breakpoints.md;
  static bool isLg(double width) => width >= Breakpoints.lg;
  static bool isXl(double width) => width >= Breakpoints.xl;

  static double pagePaddingFor(double width) {
    if (isLg(width)) return AppSpacing.pagePaddingDesktop;
    if (isSm(width)) return AppSpacing.pagePaddingTablet;
    return AppSpacing.pagePaddingMobile;
  }
}
