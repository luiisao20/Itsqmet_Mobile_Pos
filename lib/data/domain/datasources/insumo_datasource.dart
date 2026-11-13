import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/insumo_model.dart';

abstract interface class InsumoDatasource {
  Future<PageResult<InsumoModel>> getInsumos({int page = 0, int size = 100});

  Future<List<InsumoModel>> getStockBajo();

  Future<InsumoModel> createInsumo(InsumoRequest request);

  Future<InsumoModel> updateInsumo(int id, InsumoRequest request);

  Future<void> deleteInsumo(int id);
}
