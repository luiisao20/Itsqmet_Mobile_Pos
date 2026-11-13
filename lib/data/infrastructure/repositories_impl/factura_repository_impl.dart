import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/factura_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/factura_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/pago_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/factura.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/pago.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/factura_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/factura_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/pago_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/factura_model.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/pago_model.dart';

class FacturaRepositoryImpl implements FacturaRepository {
  FacturaRepositoryImpl(this._datasource);

  final FacturaDatasource _datasource;

  @override
  Future<PageResult<Factura>> getFacturas({int page = 0, int size = 10}) =>
      ErrorMapper.guard(() async {
        final result = await _datasource.getFacturas(page: page, size: size);
        return result.map(FacturaMapper.toEntity);
      });

  @override
  Future<Factura> getFactura(int id) => ErrorMapper.guard(
    () async => FacturaMapper.toEntity(await _datasource.getFactura(id)),
  );

  @override
  Future<PageResult<Factura>> getMisFacturas({int page = 0, int size = 50}) =>
      ErrorMapper.guard(() async {
        final result = await _datasource.getMisFacturas(page: page, size: size);
        return result.map(FacturaMapper.toEntity);
      });

  @override
  Future<Factura> emitirFactura(FacturaDraft draft) => ErrorMapper.guard(
    () async => FacturaMapper.toEntity(
      await _datasource.emitirFactura(FacturaRequest.fromDraft(draft)),
    ),
  );

  @override
  Future<Pago> registrarPago(PagoDraft draft) => ErrorMapper.guard(
    () async => PagoMapper.toEntity(
      await _datasource.registrarPago(PagoRequest.fromDraft(draft)),
    ),
  );

  @override
  Future<List<Pago>> getPagosByFactura(int idFactura) =>
      ErrorMapper.guard(() async {
        final pagos = await _datasource.getPagosByFactura(idFactura);
        return pagos.map(PagoMapper.toEntity).toList(growable: false);
      });
}
