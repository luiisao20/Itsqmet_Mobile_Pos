import 'package:equatable/equatable.dart';

class Plato extends Equatable {
  const Plato({
    required this.id,
    required this.idCategoria,
    this.nombreCategoria,
    required this.nombre,
    this.descripcion,
    required this.precioUnitario,
    required this.aplicaIva,
    required this.disponible,
    this.urlImagen,
    this.createdAt,
  });

  final int id;
  final int idCategoria;
  final String? nombreCategoria;
  final String nombre;
  final String? descripcion;
  final double precioUnitario;
  final bool aplicaIva;
  final bool disponible;
  final String? urlImagen;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    idCategoria,
    nombreCategoria,
    nombre,
    descripcion,
    precioUnitario,
    aplicaIva,
    disponible,
    urlImagen,
    createdAt,
  ];
}
