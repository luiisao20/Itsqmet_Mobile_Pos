import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class MesaDraft extends Equatable {
  const MesaDraft({
    required this.numeroMesa,
    required this.capacidad,
    this.ubicacion,
    this.estado,
  });

  final int numeroMesa;
  final int capacidad;
  final String? ubicacion;
  final EstadoMesa? estado;

  @override
  List<Object?> get props => [numeroMesa, capacidad, ubicacion, estado];
}
