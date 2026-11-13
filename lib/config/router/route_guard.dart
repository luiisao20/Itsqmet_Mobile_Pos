import 'dart:async';

import 'package:itsqmet_mobile_pos/config/router/app_route.dart';

class RouteRequest {
  const RouteRequest({required this.uri, this.route});

  final Uri uri;
  final AppRoute? route;

  String get location => uri.toString();

  String get path => uri.path;
}

abstract interface class RouteGuard {
  FutureOr<String?> redirect(RouteRequest request);
}

class AllowAllRouteGuard implements RouteGuard {
  const AllowAllRouteGuard();

  @override
  String? redirect(RouteRequest request) => null;
}
