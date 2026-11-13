import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/insumo_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/insumo.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';

abstract interface class InsumoRepository {
  Future<PageResult<Insumo>> getInsumos({int page = 0, int size = 100});

  Future<List<Insumo>> getStockBajo();

  Future<Insumo> createInsumo(InsumoDraft draft);

  Future<Insumo> updateInsumo(int id, InsumoDraft draft);

  Future<void> deleteInsumo(int id);
}
