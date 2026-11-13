import 'package:flutter/painting.dart';

abstract final class AppShadows {
  static const Color _black05 = Color(0x0D000000);
  static const Color _black10 = Color(0x1A000000);

  static const List<BoxShadow> xs = [
    BoxShadow(color: _black05, offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: _black10, offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(
      color: _black10,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: _black10,
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: _black10,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: _black10,
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: _black10,
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: _black10,
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: _black10,
      offset: Offset(0, 8),
      blurRadius: 10,
      spreadRadius: -6,
    ),
  ];
}
