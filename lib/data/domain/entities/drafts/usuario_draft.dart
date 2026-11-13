import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class UsuarioDraft extends Equatable {
  const UsuarioDraft({
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.email,
    this.password,
    required this.rol,
    required this.activo,
  });

  final String nombre;
  final String apellido;
  final String cedula;
  final String email;
  final String? password;
  final Rol rol;
  final bool activo;

  @override
  List<Object?> get props => [
    nombre,
    apellido,
    cedula,
    email,
    password,
    rol,
    activo,
  ];
}
