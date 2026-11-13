import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/mesa_model.dart';

abstract final class MesaMapper {
  static Mesa toEntity(MesaModel model) => Mesa(
    id: model.id,
    numeroMesa: model.numeroMesa,
    capacidad: model.capacidad,
    ubicacion: model.ubicacion,
    estado: model.estado,
    createdAt: model.createdAt,
  );
}
