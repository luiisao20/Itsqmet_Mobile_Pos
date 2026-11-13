import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/factura_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pago_model.dart';

abstract interface class FacturaDatasource {
  Future<PageResult<FacturaModel>> getFacturas({int page = 0, int size = 10});

  Future<FacturaModel> getFactura(int id);

  Future<PageResult<FacturaModel>> getMisFacturas({
    int page = 0,
    int size = 50,
  });

  Future<FacturaModel> emitirFactura(FacturaRequest request);

  Future<PagoModel> registrarPago(PagoRequest request);

  Future<List<PagoModel>> getPagosByFactura(int idFactura);
}
