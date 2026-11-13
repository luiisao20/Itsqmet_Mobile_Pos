import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 28;
  static const double s8 = 32;
  static const double s9 = 36;
  static const double s10 = 40;
  static const double s11 = 44;
  static const double s12 = 48;

  static const double pagePaddingMobile = 16;
  static const double pagePaddingTablet = 24;
  static const double pagePaddingDesktop = 32;

  static const double pageVertical = 32;

  static const SizedBox h4 = SizedBox(height: s1);
  static const SizedBox h8 = SizedBox(height: s2);
  static const SizedBox h12 = SizedBox(height: s3);
  static const SizedBox h16 = SizedBox(height: s4);
  static const SizedBox h20 = SizedBox(height: s5);
  static const SizedBox h24 = SizedBox(height: s6);
  static const SizedBox h32 = SizedBox(height: s8);
  static const SizedBox h48 = SizedBox(height: s12);

  static const SizedBox w4 = SizedBox(width: s1);
  static const SizedBox w8 = SizedBox(width: s2);
  static const SizedBox w12 = SizedBox(width: s3);
  static const SizedBox w16 = SizedBox(width: s4);
  static const SizedBox w20 = SizedBox(width: s5);
  static const SizedBox w24 = SizedBox(width: s6);
  static const SizedBox w32 = SizedBox(width: s8);
}
