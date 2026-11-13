import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/detalle_pedido_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pedido_model.dart';

abstract final class PedidoMapper {
  static Pedido toEntity(PedidoModel model) => Pedido(
    id: model.id,
    idMesa: model.idMesa,
    numeroMesa: model.numeroMesa,
    idUsuario: model.idUsuario,
    nombreUsuario: model.nombreUsuario,
    idCliente: model.idCliente,
    razonSocialCliente: model.razonSocialCliente,
    fechaApertura: model.fechaApertura,
    fechaCierre: model.fechaCierre,
    estado: model.estado,
    tipo: model.tipo,
    observaciones: model.observaciones,
    detalles: model.detalles
        .map(DetallePedidoMapper.toEntity)
        .toList(growable: false),
    createdAt: model.createdAt,
  );
}
