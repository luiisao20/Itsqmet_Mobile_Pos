import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class MesaModel {
  const MesaModel({
    required this.id,
    required this.numeroMesa,
    required this.capacidad,
    this.ubicacion,
    required this.estado,
    this.createdAt,
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) {
    return MesaModel(
      id: parseInt(json['id']) ?? 0,
      numeroMesa: parseInt(json['numeroMesa']) ?? 0,
      capacidad: parseInt(json['capacidad']) ?? 0,
      ubicacion: parseString(json['ubicacion']),
      estado: parseEnum(
        json['estado'],
        EstadoMesa.fromJson,
        orElse: EstadoMesa.libre,
      ),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final int numeroMesa;
  final int capacidad;
  final String? ubicacion;
  final EstadoMesa estado;
  final DateTime? createdAt;
}

class MesaRequest {
  const MesaRequest({
    required this.numeroMesa,
    required this.capacidad,
    this.ubicacion,
    this.estado,
  });

  factory MesaRequest.fromDraft(MesaDraft draft) => MesaRequest(
    numeroMesa: draft.numeroMesa,
    capacidad: draft.capacidad,
    ubicacion: draft.ubicacion,
    estado: draft.estado,
  );

  final int numeroMesa;
  final int capacidad;
  final String? ubicacion;
  final EstadoMesa? estado;

  Map<String, dynamic> toJson() => {
    'numeroMesa': numeroMesa,
    'capacidad': capacidad,
    if (ubicacion != null) 'ubicacion': ubicacion,
    if (estado != null) 'estado': estado!.toJson(),
  };
}
