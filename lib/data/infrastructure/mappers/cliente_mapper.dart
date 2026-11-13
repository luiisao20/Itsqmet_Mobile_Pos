import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/cliente_model.dart';

abstract final class ClienteMapper {
  static Cliente toEntity(ClienteModel model) => Cliente(
    uuid: model.uuid,
    tipoIdentificacion: model.tipoIdentificacion,
    identificacion: model.identificacion,
    razonSocial: model.razonSocial,
    direccion: model.direccion,
    telefono: model.telefono,
    email: model.email,
    activo: model.activo,
    createdAt: model.createdAt,
  );
}
