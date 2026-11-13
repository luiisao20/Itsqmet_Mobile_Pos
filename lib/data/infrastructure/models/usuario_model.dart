import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class UsuarioModel {
  const UsuarioModel({
    required this.uuid,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.email,
    required this.rol,
    required this.activo,
    this.createdAt,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      uuid: parseString(json['uuid']) ?? '',
      nombre: parseString(json['nombre']) ?? '',
      apellido: parseString(json['apellido']) ?? '',
      cedula: parseString(json['cedula']) ?? '',
      email: parseString(json['email']) ?? '',
      rol: parseEnum(json['rol'], Rol.fromJson, orElse: Rol.cliente),
      activo: parseBool(json['activo']) ?? true,
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  final String uuid;
  final String nombre;
  final String apellido;
  final String cedula;
  final String email;
  final Rol rol;
  final bool activo;
  final DateTime? createdAt;
}

class UsuarioRequest {
  const UsuarioRequest({
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.email,
    this.password,
    required this.rol,
    required this.activo,
  });

  factory UsuarioRequest.fromDraft(UsuarioDraft draft) => UsuarioRequest(
    nombre: draft.nombre,
    apellido: draft.apellido,
    cedula: draft.cedula,
    email: draft.email,
    password: draft.password,
    rol: draft.rol,
    activo: draft.activo,
  );

  final String nombre;
  final String apellido;
  final String cedula;
  final String email;
  final String? password;
  final Rol rol;
  final bool activo;

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'cedula': cedula,
    'email': email,
    if (password != null) 'password': password,
    'rol': rol.toJson(),
    'activo': activo,
  };
}
