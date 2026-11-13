import 'package:get_it/get_it.dart';
import 'package:itsqmet_mobile_pos/config/router/route_guard.dart';
import 'package:itsqmet_mobile_pos/config/router/router_refresh_notifier.dart';

void registerRouterDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<RouterRefreshNotifier>(
      RouterRefreshNotifier.new,
      dispose: (notifier) => notifier.dispose(),
    )
    ..registerLazySingleton<RouteGuard>(AllowAllRouteGuard.new);
}

void overrideRouteGuard(GetIt getIt, RouteGuard Function() factory) {
  if (getIt.isRegistered<RouteGuard>()) {
    getIt.unregister<RouteGuard>();
  }
  getIt.registerLazySingleton<RouteGuard>(factory);
}
