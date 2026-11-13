import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/auth_user.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/rol.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._(this.status, this.user);

  const AuthState.unknown() : this._(AuthStatus.unknown, null);

  const AuthState.authenticated(AuthUser user)
    : this._(AuthStatus.authenticated, user);

  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated, null);

  final AuthStatus status;
  final AuthUser? user;

  bool get isUnknown => status == AuthStatus.unknown;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  Rol? get rol => user?.rol;

  @override
  List<Object?> get props => [status, user];
}
