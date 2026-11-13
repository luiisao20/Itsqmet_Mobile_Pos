import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/factura_model.dart';

abstract final class FacturaMapper {
  static Factura toEntity(FacturaModel model) => Factura(
    id: model.id,
    idPedido: model.idPedido,
    idCliente: model.idCliente,
    razonSocialCliente: model.razonSocialCliente,
    identificacionCliente: model.identificacionCliente,
    idUsuario: model.idUsuario,
    nombreUsuario: model.nombreUsuario,
    numeroSecuencial: model.numeroSecuencial,
    claveAccesoSri: model.claveAccesoSri,
    fechaEmision: model.fechaEmision,
    subtotal: model.subtotal,
    subtotalIva: model.subtotalIva,
    propina: model.propina,
    total: model.total,
    estado: model.estado,
    createdAt: model.createdAt,
  );
}
