import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class CategoriaPlatoModel {
  const CategoriaPlatoModel({
    required this.id,
    required this.nombre,
    required this.areaImpresion,
    this.ordenVisual,
    this.createdAt,
  });

  factory CategoriaPlatoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaPlatoModel(
      id: parseInt(json['id']) ?? 0,
      nombre: parseString(json['nombre']) ?? '',
      areaImpresion: parseEnum(
        json['areaImpresion'],
        AreaImpresion.fromJson,
        orElse: AreaImpresion.cocina,
      ),
      ordenVisual: parseInt(json['ordenVisual']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final String nombre;
  final AreaImpresion areaImpresion;
  final int? ordenVisual;
  final DateTime? createdAt;
}

class CategoriaPlatoRequest {
  const CategoriaPlatoRequest({
    required this.nombre,
    required this.areaImpresion,
    this.ordenVisual,
  });

  factory CategoriaPlatoRequest.fromDraft(CategoriaPlatoDraft draft) =>
      CategoriaPlatoRequest(
        nombre: draft.nombre,
        areaImpresion: draft.areaImpresion,
        ordenVisual: draft.ordenVisual,
      );

  final String nombre;
  final AreaImpresion areaImpresion;
  final int? ordenVisual;

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'areaImpresion': areaImpresion.toJson(),
    if (ordenVisual != null) 'ordenVisual': ordenVisual,
  };
}
