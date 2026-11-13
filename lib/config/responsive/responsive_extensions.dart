import 'package:flutter/widgets.dart';
import 'package:itsqmet_mobile_pos/config/responsive/breakpoints.dart';

extension ResponsiveContext on BuildContext {
  DeviceType get deviceType =>
      Breakpoints.deviceTypeFor(MediaQuery.sizeOf(this).shortestSide);

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;

  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  bool get atLeastSm => ScreenSize.isSm(screenWidth);
  bool get atLeastMd => ScreenSize.isMd(screenWidth);
  bool get atLeastLg => ScreenSize.isLg(screenWidth);
  bool get atLeastXl => ScreenSize.isXl(screenWidth);

  double get pagePadding => ScreenSize.pagePaddingFor(screenWidth);
}
