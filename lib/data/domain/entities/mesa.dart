import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class Mesa extends Equatable {
  const Mesa({
    required this.id,
    required this.numeroMesa,
    required this.capacidad,
    this.ubicacion,
    required this.estado,
    this.createdAt,
  });

  final int id;
  final int numeroMesa;
  final int capacidad;
  final String? ubicacion;
  final EstadoMesa estado;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    numeroMesa,
    capacidad,
    ubicacion,
    estado,
    createdAt,
  ];
}
