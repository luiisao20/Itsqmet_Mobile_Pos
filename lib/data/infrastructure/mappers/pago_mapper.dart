import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pago_model.dart';

abstract final class PagoMapper {
  static Pago toEntity(PagoModel model) => Pago(
    id: model.id,
    idFactura: model.idFactura,
    numeroSecuencialFactura: model.numeroSecuencialFactura,
    metodoPago: model.metodoPago,
    monto: model.monto,
    referenciaTransaccion: model.referenciaTransaccion,
    fechaPago: model.fechaPago,
  );
}
