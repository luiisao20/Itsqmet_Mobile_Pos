import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class Cliente extends Equatable {
  const Cliente({
    required this.uuid,
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.razonSocial,
    this.direccion,
    this.telefono,
    this.email,
    this.activo,
    this.createdAt,
  });

  final String uuid;
  final TipoIdentificacion tipoIdentificacion;
  final String identificacion;
  final String razonSocial;
  final String? direccion;
  final String? telefono;
  final String? email;
  final bool? activo;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    uuid,
    tipoIdentificacion,
    identificacion,
    razonSocial,
    direccion,
    telefono,
    email,
    activo,
    createdAt,
  ];
}
