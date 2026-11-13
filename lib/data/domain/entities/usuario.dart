import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class Usuario extends Equatable {
  const Usuario({
    required this.uuid,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.email,
    required this.rol,
    required this.activo,
    this.createdAt,
  });

  final String uuid;
  final String nombre;
  final String apellido;
  final String cedula;
  final String email;
  final Rol rol;
  final bool activo;
  final DateTime? createdAt;

  String get fullName => '$nombre $apellido'.trim();

  @override
  List<Object?> get props => [
    uuid,
    nombre,
    apellido,
    cedula,
    email,
    rol,
    activo,
    createdAt,
  ];
}
