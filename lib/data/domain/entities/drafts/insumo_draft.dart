import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class InsumoDraft extends Equatable {
  const InsumoDraft({
    required this.nombre,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.costoPromedio,
  });

  final String nombre;
  final UnidadMedida unidadMedida;
  final double stockActual;
  final double stockMinimo;
  final double costoPromedio;

  @override
  List<Object?> get props => [
    nombre,
    unidadMedida,
    stockActual,
    stockMinimo,
    costoPromedio,
  ];
}
