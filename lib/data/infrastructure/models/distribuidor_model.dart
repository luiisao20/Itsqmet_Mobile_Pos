import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';

class DistribuidorModel {
  const DistribuidorModel({
    required this.id,
    required this.ruc,
    required this.razonSocial,
    this.nombreContacto,
    this.telefono,
    this.email,
    this.direccion,
    this.categoriaProveedor,
    this.createdAt,
  });

  factory DistribuidorModel.fromJson(Map<String, dynamic> json) {
    return DistribuidorModel(
      id: parseInt(json['id']) ?? 0,
      ruc: parseString(json['ruc']) ?? '',
      razonSocial: parseString(json['razonSocial']) ?? '',
      nombreContacto: parseString(json['nombreContacto']),
      telefono: parseString(json['telefono']),
      email: parseString(json['email']),
      direccion: parseString(json['direccion']),
      categoriaProveedor: parseString(json['categoriaProveedor']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final String ruc;
  final String razonSocial;
  final String? nombreContacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? categoriaProveedor;
  final DateTime? createdAt;
}

class DistribuidorRequest {
  const DistribuidorRequest({
    required this.ruc,
    required this.razonSocial,
    this.nombreContacto,
    this.telefono,
    this.email,
    this.direccion,
    this.categoriaProveedor,
  });

  factory DistribuidorRequest.fromDraft(DistribuidorDraft draft) =>
      DistribuidorRequest(
        ruc: draft.ruc,
        razonSocial: draft.razonSocial,
        nombreContacto: draft.nombreContacto,
        telefono: draft.telefono,
        email: draft.email,
        direccion: draft.direccion,
        categoriaProveedor: draft.categoriaProveedor,
      );

  final String ruc;
  final String razonSocial;
  final String? nombreContacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? categoriaProveedor;

  Map<String, dynamic> toJson() => {
    'ruc': ruc,
    'razonSocial': razonSocial,
    if (nombreContacto != null) 'nombreContacto': nombreContacto,
    if (telefono != null) 'telefono': telefono,
    if (email != null) 'email': email,
    if (direccion != null) 'direccion': direccion,
    if (categoriaProveedor != null) 'categoriaProveedor': categoriaProveedor,
  };
}
