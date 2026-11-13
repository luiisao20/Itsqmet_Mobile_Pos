import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class ClienteDraft extends Equatable {
  const ClienteDraft({
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.razonSocial,
    this.direccion,
    this.telefono,
    this.email,
    this.password,
    this.activo,
  });

  final TipoIdentificacion tipoIdentificacion;
  final String identificacion;
  final String razonSocial;
  final String? direccion;
  final String? telefono;
  final String? email;
  final String? password;
  final bool? activo;

  @override
  List<Object?> get props => [
    tipoIdentificacion,
    identificacion,
    razonSocial,
    direccion,
    telefono,
    email,
    password,
    activo,
  ];
}
