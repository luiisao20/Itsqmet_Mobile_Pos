import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';

void main() {
  test('getIt is the shared GetIt instance', () {
    expect(identical(getIt, GetIt.instance), isTrue);
  });

  test('setupLocator completes without registering anything yet', () async {
    await expectLater(setupLocator(), completes);
  });
}
