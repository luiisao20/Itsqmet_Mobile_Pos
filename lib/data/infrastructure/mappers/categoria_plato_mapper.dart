import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/categoria_plato_model.dart';

abstract final class CategoriaPlatoMapper {
  static CategoriaPlato toEntity(CategoriaPlatoModel model) => CategoriaPlato(
    id: model.id,
    nombre: model.nombre,
    areaImpresion: model.areaImpresion,
    ordenVisual: model.ordenVisual,
    createdAt: model.createdAt,
  );
}
