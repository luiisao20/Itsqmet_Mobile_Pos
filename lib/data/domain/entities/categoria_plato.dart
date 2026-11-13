import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class CategoriaPlato extends Equatable {
  const CategoriaPlato({
    required this.id,
    required this.nombre,
    required this.areaImpresion,
    this.ordenVisual,
    this.createdAt,
  });

  final int id;
  final String nombre;
  final AreaImpresion areaImpresion;
  final int? ordenVisual;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    nombre,
    areaImpresion,
    ordenVisual,
    createdAt,
  ];
}
