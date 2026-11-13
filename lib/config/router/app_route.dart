import 'package:itsqmet_mobile_pos/data/domain/enums/rol.dart';

enum RouteAccess { public, guestOnly, authenticated }

class AppRoute {
  const AppRoute({
    required this.name,
    required this.path,
    this.access = RouteAccess.public,
    this.allowedRoles = const <Rol>{},
  });

  final String name;
  final String path;
  final RouteAccess access;
  final Set<Rol> allowedRoles;

  bool get isGuestOnly => access == RouteAccess.guestOnly;

  bool get requiresAuth => access == RouteAccess.authenticated;

  bool allowsRole(Rol rol) =>
      allowedRoles.isEmpty || allowedRoles.contains(rol);

  @override
  String toString() => 'AppRoute($name, $path)';
}
