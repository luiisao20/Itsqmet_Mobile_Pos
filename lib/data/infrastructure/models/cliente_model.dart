import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class ClienteModel {
  const ClienteModel({
    required this.uuid,
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.razonSocial,
    this.direccion,
    this.telefono,
    this.email,
    this.activo,
    this.createdAt,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      uuid: parseString(json['uuid']) ?? '',
      tipoIdentificacion: parseEnum(
        json['tipoIdentificacion'],
        TipoIdentificacion.fromJson,
        orElse: TipoIdentificacion.cedula,
      ),
      identificacion: parseString(json['identificacion']) ?? '',
      razonSocial: parseString(json['razonSocial']) ?? '',
      direccion: parseString(json['direccion']),
      telefono: parseString(json['telefono']),
      email: parseString(json['email']),
      activo: parseBool(json['activo']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  final String uuid;
  final TipoIdentificacion tipoIdentificacion;
  final String identificacion;
  final String razonSocial;
  final String? direccion;
  final String? telefono;
  final String? email;
  final bool? activo;
  final DateTime? createdAt;
}

class ClienteRequest {
  const ClienteRequest({
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.razonSocial,
    this.direccion,
    this.telefono,
    this.email,
    this.password,
    this.activo,
  });

  factory ClienteRequest.fromDraft(ClienteDraft draft) => ClienteRequest(
    tipoIdentificacion: draft.tipoIdentificacion,
    identificacion: draft.identificacion,
    razonSocial: draft.razonSocial,
    direccion: draft.direccion,
    telefono: draft.telefono,
    email: draft.email,
    password: draft.password,
    activo: draft.activo,
  );

  final TipoIdentificacion tipoIdentificacion;
  final String identificacion;
  final String razonSocial;
  final String? direccion;
  final String? telefono;
  final String? email;
  final String? password;
  final bool? activo;

  Map<String, dynamic> toJson() => {
    'tipoIdentificacion': tipoIdentificacion.toJson(),
    'identificacion': identificacion,
    'razonSocial': razonSocial,
    if (direccion != null) 'direccion': direccion,
    if (telefono != null) 'telefono': telefono,
    if (email != null) 'email': email,
    if (password != null) 'password': password,
    if (activo != null) 'activo': activo,
  };
}
