import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.uuid,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    required this.activo,
  });

  final String uuid;
  final String nombre;
  final String apellido;
  final String email;
  final Rol rol;
  final bool activo;

  String get fullName => '$nombre $apellido'.trim();

  String get initial {
    final source = nombre.trim().isNotEmpty ? nombre.trim() : email.trim();
    if (source.isEmpty) return '?';
    return String.fromCharCode(source.runes.first).toUpperCase();
  }

  @override
  List<Object?> get props => [uuid, nombre, apellido, email, rol, activo];
}
