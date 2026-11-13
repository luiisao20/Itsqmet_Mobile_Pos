import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/usuario_model.dart';

abstract final class UsuarioMapper {
  static Usuario toEntity(UsuarioModel model) => Usuario(
    uuid: model.uuid,
    nombre: model.nombre,
    apellido: model.apellido,
    cedula: model.cedula,
    email: model.email,
    rol: model.rol,
    activo: model.activo,
    createdAt: model.createdAt,
  );
}
