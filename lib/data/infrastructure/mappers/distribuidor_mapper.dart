import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/distribuidor_model.dart';

abstract final class DistribuidorMapper {
  static Distribuidor toEntity(DistribuidorModel model) => Distribuidor(
    id: model.id,
    ruc: model.ruc,
    razonSocial: model.razonSocial,
    nombreContacto: model.nombreContacto,
    telefono: model.telefono,
    email: model.email,
    direccion: model.direccion,
    categoriaProveedor: model.categoriaProveedor,
    createdAt: model.createdAt,
  );
}
