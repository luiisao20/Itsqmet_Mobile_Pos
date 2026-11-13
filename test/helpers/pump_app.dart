import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

abstract final class TestScreens {
  static const Size phone = Size(390, 844);
  static const Size tabletLandscape = Size(1024, 768);
  static const Size tabletPortrait = Size(800, 1280);
}

extension PumpAppX on WidgetTester {
  void setScreenSize(Size size) {
    view.devicePixelRatio = 1;
    view.physicalSize = size;
    addTearDown(view.reset);
  }

  Future<void> pumpApp(
    Widget child, {
    Size size = TestScreens.phone,
    bool withScaffold = true,
  }) async {
    setScreenSize(size);
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: withScaffold ? Scaffold(body: child) : child,
      ),
    );
  }
}
