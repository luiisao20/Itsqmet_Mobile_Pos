import 'dart:async';

import 'package:itsqmet_mobile_pos/config/router/app_route.dart';
import 'package:itsqmet_mobile_pos/config/router/app_routes.dart';
import 'package:itsqmet_mobile_pos/config/router/route_guard.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/rol.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_cubit.dart';

class AuthRouteGuard implements RouteGuard {
  const AuthRouteGuard(this._auth);

  static const String returnUrlParam = 'returnUrl';

  final AuthCubit _auth;

  @override
  FutureOr<String?> redirect(RouteRequest request) {
    if (_auth.state.isUnknown) {
      return _auth.ensureRestored().then((_) => _decide(request));
    }
    return _decide(request);
  }

  String? _decide(RouteRequest request) {
    final route = request.route;
    if (route == null) return null;
    final rol = _auth.state.rol;

    return switch (route.access) {
      RouteAccess.public => null,
      RouteAccess.guestOnly => rol == null ? null : _afterLogin(request, rol),
      RouteAccess.authenticated =>
        rol == null
            ? AppRoutes.login.path
            : route.allowsRole(rol)
            ? null
            : AppRoutes.home.path,
    };
  }

  static String _afterLogin(RouteRequest request, Rol rol) {
    final returnUrl = request.uri.queryParameters[returnUrlParam];
    final target = returnUrl == null ? null : Uri.tryParse(returnUrl);
    if (target != null && _isAllowedTarget(target, rol)) {
      return target.toString();
    }
    return AppRoutes.homeForRole(rol).path;
  }

  static bool _isAllowedTarget(Uri target, Rol rol) {
    if (target.hasScheme || target.hasAuthority) return false;
    if (!target.path.startsWith('/')) return false;
    final route = AppRoutes.match(target.path);
    if (route == null || route.isGuestOnly) return false;
    return !route.requiresAuth || route.allowsRole(rol);
  }
}
