import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/insumo_model.dart';

abstract final class InsumoMapper {
  static Insumo toEntity(InsumoModel model) => Insumo(
    id: model.id,
    nombre: model.nombre,
    unidadMedida: model.unidadMedida,
    stockActual: model.stockActual,
    stockMinimo: model.stockMinimo,
    costoPromedio: model.costoPromedio,
    stockBajo: model.stockBajo ?? model.stockActual <= model.stockMinimo,
    createdAt: model.createdAt,
  );
}
