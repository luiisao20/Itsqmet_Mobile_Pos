import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/drafts.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.uuid,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    required this.activo,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      uuid: parseString(json['uuid']) ?? '',
      nombre: parseString(json['nombre']) ?? '',
      apellido: parseString(json['apellido']) ?? '',
      email: parseString(json['email']) ?? '',
      rol: parseEnum(json['rol'], Rol.fromJson, orElse: Rol.cliente),
      activo: parseBool(json['activo']) ?? true,
      message: parseString(json['message']),
    );
  }

  final String uuid;
  final String nombre;
  final String apellido;
  final String email;
  final Rol rol;
  final bool activo;
  final String? message;

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    'rol': rol.toJson(),
    'activo': activo,
    if (message != null) 'message': message,
  };
}

class AuthSessionModel {
  const AuthSessionModel({required this.user, required this.token});

  final AuthResponseModel user;
  final String token;
}

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class ClienteLoginRequest {
  const ClienteLoginRequest({required this.login, required this.password});

  final String login;
  final String password;

  Map<String, dynamic> toJson() => {'login': login, 'password': password};
}

class ClienteRegistrationRequest {
  const ClienteRegistrationRequest({
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.razonSocial,
    this.direccion,
    this.telefono,
    required this.email,
    required this.password,
  });

  factory ClienteRegistrationRequest.fromDraft(
    ClienteRegistrationDraft draft,
  ) => ClienteRegistrationRequest(
    tipoIdentificacion: draft.tipoIdentificacion,
    identificacion: draft.identificacion,
    razonSocial: draft.razonSocial,
    direccion: draft.direccion,
    telefono: draft.telefono,
    email: draft.email,
    password: draft.password,
  );

  final TipoIdentificacion tipoIdentificacion;
  final String identificacion;
  final String razonSocial;
  final String? direccion;
  final String? telefono;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
    'tipoIdentificacion': tipoIdentificacion.toJson(),
    'identificacion': identificacion,
    'razonSocial': razonSocial,
    if (direccion != null) 'direccion': direccion,
    if (telefono != null) 'telefono': telefono,
    'email': email,
    'password': password,
  };
}
