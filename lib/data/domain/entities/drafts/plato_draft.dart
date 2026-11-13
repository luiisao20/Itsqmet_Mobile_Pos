import 'package:equatable/equatable.dart';

class PlatoDraft extends Equatable {
  const PlatoDraft({
    required this.idCategoria,
    required this.nombre,
    this.descripcion,
    required this.precioUnitario,
    required this.aplicaIva,
    required this.disponible,
    this.urlImagen,
  });

  final int idCategoria;
  final String nombre;
  final String? descripcion;
  final double precioUnitario;
  final bool aplicaIva;
  final bool disponible;
  final String? urlImagen;

  @override
  List<Object?> get props => [
    idCategoria,
    nombre,
    descripcion,
    precioUnitario,
    aplicaIva,
    disponible,
    urlImagen,
  ];
}
