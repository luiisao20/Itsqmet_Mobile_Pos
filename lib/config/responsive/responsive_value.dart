import 'package:flutter/widgets.dart';
import 'package:itsqmet_mobile_pos/config/responsive/breakpoints.dart';

T responsiveValueFor<T>(
  double width, {
  required T base,
  T? sm,
  T? md,
  T? lg,
  T? xl,
}) {
  if (xl != null && ScreenSize.isXl(width)) return xl;
  if (lg != null && ScreenSize.isLg(width)) return lg;
  if (md != null && ScreenSize.isMd(width)) return md;
  if (sm != null && ScreenSize.isSm(width)) return sm;
  return base;
}

T responsive<T>(
  BuildContext context, {
  required T base,
  T? sm,
  T? md,
  T? lg,
  T? xl,
}) {
  return responsiveValueFor<T>(
    MediaQuery.sizeOf(context).width,
    base: base,
    sm: sm,
    md: md,
    lg: lg,
    xl: xl,
  );
}

@immutable
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.base,
    this.sm,
    this.md,
    this.lg,
    this.xl,
  });

  final T base;
  final T? sm;
  final T? md;
  final T? lg;
  final T? xl;

  T resolve(double width) =>
      responsiveValueFor<T>(width, base: base, sm: sm, md: md, lg: lg, xl: xl);

  T of(BuildContext context) => resolve(MediaQuery.sizeOf(context).width);
}
