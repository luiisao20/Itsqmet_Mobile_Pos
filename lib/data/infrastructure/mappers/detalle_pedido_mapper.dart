import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/detalle_pedido_model.dart';

abstract final class DetallePedidoMapper {
  static DetallePedido toEntity(DetallePedidoModel model) => DetallePedido(
    id: model.id,
    idPedido: model.idPedido,
    idPlato: model.idPlato,
    nombrePlato: model.nombrePlato,
    cantidad: model.cantidad,
    precioUnitario: model.precioUnitario,
    subtotal: model.subtotal,
    notasPreparacion: model.notasPreparacion,
    estado: model.estado,
  );
}
