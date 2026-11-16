import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/services/notifications/app_foreground.dart';

void main() {
  group('isAppVisible', () {
    test('unset, resumed and inactive count as visible', () {
      expect(isAppVisible(null), isTrue);
      expect(isAppVisible(AppLifecycleState.resumed), isTrue);
      expect(isAppVisible(AppLifecycleState.inactive), isTrue);
    });

    test('paused, hidden and detached count as background', () {
      expect(isAppVisible(AppLifecycleState.paused), isFalse);
      expect(isAppVisible(AppLifecycleState.hidden), isFalse);
      expect(isAppVisible(AppLifecycleState.detached), isFalse);
    });
  });
}
