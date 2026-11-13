import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/factura_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/pago_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/factura.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/pago.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';

abstract interface class FacturaRepository {
  Future<PageResult<Factura>> getFacturas({int page = 0, int size = 10});

  Future<Factura> getFactura(int id);

  Future<PageResult<Factura>> getMisFacturas({int page = 0, int size = 50});

  Future<Factura> emitirFactura(FacturaDraft draft);

  Future<Pago> registrarPago(PagoDraft draft);

  Future<List<Pago>> getPagosByFactura(int idFactura);
}
