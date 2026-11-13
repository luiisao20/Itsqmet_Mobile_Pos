import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';

class PlatoModel {
  const PlatoModel({
    required this.id,
    required this.idCategoria,
    this.nombreCategoria,
    required this.nombre,
    this.descripcion,
    required this.precioUnitario,
    required this.aplicaIva,
    required this.disponible,
    this.urlImagen,
    this.createdAt,
  });

  factory PlatoModel.fromJson(Map<String, dynamic> json) {
    return PlatoModel(
      id: parseInt(json['id']) ?? 0,
      idCategoria: parseInt(json['idCategoria']) ?? 0,
      nombreCategoria: parseString(json['nombreCategoria']),
      nombre: parseString(json['nombre']) ?? '',
      descripcion: parseString(json['descripcion']),
      precioUnitario: parseDouble(json['precioUnitario']) ?? 0,
      aplicaIva: parseBool(json['aplicaIva']) ?? false,
      disponible: parseBool(json['disponible']) ?? true,
      urlImagen: parseString(json['urlImagen']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final int idCategoria;
  final String? nombreCategoria;
  final String nombre;
  final String? descripcion;
  final double precioUnitario;
  final bool aplicaIva;
  final bool disponible;
  final String? urlImagen;
  final DateTime? createdAt;
}

class PlatoRequest {
  const PlatoRequest({
    required this.idCategoria,
    required this.nombre,
    this.descripcion,
    required this.precioUnitario,
    required this.aplicaIva,
    required this.disponible,
    this.urlImagen,
  });

  factory PlatoRequest.fromDraft(PlatoDraft draft) => PlatoRequest(
    idCategoria: draft.idCategoria,
    nombre: draft.nombre,
    descripcion: draft.descripcion,
    precioUnitario: draft.precioUnitario,
    aplicaIva: draft.aplicaIva,
    disponible: draft.disponible,
    urlImagen: draft.urlImagen,
  );

  final int idCategoria;
  final String nombre;
  final String? descripcion;
  final double precioUnitario;
  final bool aplicaIva;
  final bool disponible;
  final String? urlImagen;

  Map<String, dynamic> toJson() => {
    'idCategoria': idCategoria,
    'nombre': nombre,
    if (descripcion != null) 'descripcion': descripcion,
    'precioUnitario': precioUnitario,
    'aplicaIva': aplicaIva,
    'disponible': disponible,
    if (urlImagen != null) 'urlImagen': urlImagen,
  };
}
