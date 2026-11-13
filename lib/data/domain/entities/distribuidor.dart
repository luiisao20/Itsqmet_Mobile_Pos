import 'package:equatable/equatable.dart';

class Distribuidor extends Equatable {
  const Distribuidor({
    required this.id,
    required this.ruc,
    required this.razonSocial,
    this.nombreContacto,
    this.telefono,
    this.email,
    this.direccion,
    this.categoriaProveedor,
    this.createdAt,
  });

  final int id;
  final String ruc;
  final String razonSocial;
  final String? nombreContacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? categoriaProveedor;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    ruc,
    razonSocial,
    nombreContacto,
    telefono,
    email,
    direccion,
    categoriaProveedor,
    createdAt,
  ];
}
