import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class ClienteRegistrationDraft extends Equatable {
  const ClienteRegistrationDraft({
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.razonSocial,
    this.direccion,
    this.telefono,
    required this.email,
    required this.password,
  });

  final TipoIdentificacion tipoIdentificacion;
  final String identificacion;
  final String razonSocial;
  final String? direccion;
  final String? telefono;
  final String email;
  final String password;

  @override
  List<Object?> get props => [
    tipoIdentificacion,
    identificacion,
    razonSocial,
    direccion,
    telefono,
    email,
    password,
  ];
}
