import 'package:equatable/equatable.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class CategoriaPlatoDraft extends Equatable {
  const CategoriaPlatoDraft({
    required this.nombre,
    required this.areaImpresion,
    this.ordenVisual,
  });

  final String nombre;
  final AreaImpresion areaImpresion;
  final int? ordenVisual;

  @override
  List<Object?> get props => [nombre, areaImpresion, ordenVisual];
}
