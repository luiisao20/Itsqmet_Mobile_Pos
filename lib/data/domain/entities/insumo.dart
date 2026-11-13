import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class Insumo extends Equatable {
  const Insumo({
    required this.id,
    required this.nombre,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.costoPromedio,
    required this.stockBajo,
    this.createdAt,
  });

  final int id;
  final String nombre;
  final UnidadMedida unidadMedida;
  final double stockActual;
  final double stockMinimo;
  final double costoPromedio;

  final bool stockBajo;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    nombre,
    unidadMedida,
    stockActual,
    stockMinimo,
    costoPromedio,
    stockBajo,
    createdAt,
  ];
}
