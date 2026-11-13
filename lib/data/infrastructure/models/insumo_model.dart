import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class InsumoModel {
  const InsumoModel({
    required this.id,
    required this.nombre,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.costoPromedio,
    this.stockBajo,
    this.createdAt,
  });

  factory InsumoModel.fromJson(Map<String, dynamic> json) {
    return InsumoModel(
      id: parseInt(json['id']) ?? 0,
      nombre: parseString(json['nombre']) ?? '',
      unidadMedida: parseEnum(
        json['unidadMedida'],
        UnidadMedida.fromJson,
        orElse: UnidadMedida.unidad,
      ),
      stockActual: parseDouble(json['stockActual']) ?? 0,
      stockMinimo: parseDouble(json['stockMinimo']) ?? 0,
      costoPromedio: parseDouble(json['costoPromedio']) ?? 0,
      stockBajo: parseBool(json['stockBajo']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final String nombre;
  final UnidadMedida unidadMedida;
  final double stockActual;
  final double stockMinimo;
  final double costoPromedio;

  final bool? stockBajo;
  final DateTime? createdAt;
}

class InsumoRequest {
  const InsumoRequest({
    required this.nombre,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.costoPromedio,
  });

  factory InsumoRequest.fromDraft(InsumoDraft draft) => InsumoRequest(
    nombre: draft.nombre,
    unidadMedida: draft.unidadMedida,
    stockActual: draft.stockActual,
    stockMinimo: draft.stockMinimo,
    costoPromedio: draft.costoPromedio,
  );

  final String nombre;
  final UnidadMedida unidadMedida;
  final double stockActual;
  final double stockMinimo;
  final double costoPromedio;

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'unidadMedida': unidadMedida.toJson(),
    'stockActual': stockActual,
    'stockMinimo': stockMinimo,
    'costoPromedio': costoPromedio,
  };
}
