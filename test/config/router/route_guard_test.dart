import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/router/router.dart';

void main() {
  test('AllowAllRouteGuard never redirects', () {
    const guard = AllowAllRouteGuard();

    for (final route in AppRoutes.all) {
      expect(
        guard.redirect(RouteRequest(uri: Uri.parse(route.path), route: route)),
        isNull,
      );
    }
    expect(
      guard.redirect(RouteRequest(uri: Uri.parse('/desconocida'))),
      isNull,
    );
  });

  test('RouteRequest exposes the location and the matched route', () {
    final request = RouteRequest(
      uri: Uri.parse('/admin?tab=platos'),
      route: AppRoutes.admin,
    );

    expect(request.location, '/admin?tab=platos');
    expect(request.path, '/admin');
    expect(request.route, AppRoutes.admin);
  });

  test('RouterRefreshNotifier.notify notifies its listeners', () {
    final notifier = RouterRefreshNotifier();
    addTearDown(notifier.dispose);
    var calls = 0;
    notifier.addListener(() => calls++);

    notifier.notify();
    notifier.notify();

    expect(calls, 2);
  });
}
