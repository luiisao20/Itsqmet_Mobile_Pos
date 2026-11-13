import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/auth_model.dart';

abstract final class AuthMapper {
  static AuthUser toEntity(AuthResponseModel model) => AuthUser(
    uuid: model.uuid,
    nombre: model.nombre,
    apellido: model.apellido,
    email: model.email,
    rol: model.rol,
    activo: model.activo,
  );

  static AuthResponseModel fromEntity(AuthUser user) => AuthResponseModel(
    uuid: user.uuid,
    nombre: user.nombre,
    apellido: user.apellido,
    email: user.email,
    rol: user.rol,
    activo: user.activo,
  );

  static Map<String, dynamic> userToJson(AuthUser user) =>
      fromEntity(user).toJson();

  static AuthUser userFromJson(Map<String, dynamic> json) =>
      toEntity(AuthResponseModel.fromJson(json));
}
