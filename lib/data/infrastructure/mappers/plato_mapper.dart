import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/plato_model.dart';

abstract final class PlatoMapper {
  static Plato toEntity(PlatoModel model) => Plato(
    id: model.id,
    idCategoria: model.idCategoria,
    nombreCategoria: model.nombreCategoria,
    nombre: model.nombre,
    descripcion: model.descripcion,
    precioUnitario: model.precioUnitario,
    aplicaIva: model.aplicaIva,
    disponible: model.disponible,
    urlImagen: model.urlImagen,
    createdAt: model.createdAt,
  );
}
