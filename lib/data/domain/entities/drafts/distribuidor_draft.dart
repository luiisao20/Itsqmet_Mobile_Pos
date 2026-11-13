import 'package:equatable/equatable.dart';

class DistribuidorDraft extends Equatable {
  const DistribuidorDraft({
    required this.ruc,
    required this.razonSocial,
    this.nombreContacto,
    this.telefono,
    this.email,
    this.direccion,
    this.categoriaProveedor,
  });

  final String ruc;
  final String razonSocial;
  final String? nombreContacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? categoriaProveedor;

  @override
  List<Object?> get props => [
    ruc,
    razonSocial,
    nombreContacto,
    telefono,
    email,
    direccion,
    categoriaProveedor,
  ];
}
