import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/insumo_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/insumo_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/insumo.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/insumo_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/insumo_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/insumo_model.dart';

class InsumoRepositoryImpl implements InsumoRepository {
  InsumoRepositoryImpl(this._datasource);

  final InsumoDatasource _datasource;

  @override
  Future<PageResult<Insumo>> getInsumos({int page = 0, int size = 100}) {
    return ErrorMapper.guard(() async {
      final result = await _datasource.getInsumos(page: page, size: size);
      return result.map(InsumoMapper.toEntity);
    });
  }

  @override
  Future<List<Insumo>> getStockBajo() {
    return ErrorMapper.guard(() async {
      final models = await _datasource.getStockBajo();
      return models.map(InsumoMapper.toEntity).toList(growable: false);
    });
  }

  @override
  Future<Insumo> createInsumo(InsumoDraft draft) {
    return ErrorMapper.guard(() async {
      final model = await _datasource.createInsumo(
        InsumoRequest.fromDraft(draft),
      );
      return InsumoMapper.toEntity(model);
    });
  }

  @override
  Future<Insumo> updateInsumo(int id, InsumoDraft draft) {
    return ErrorMapper.guard(() async {
      final model = await _datasource.updateInsumo(
        id,
        InsumoRequest.fromDraft(draft),
      );
      return InsumoMapper.toEntity(model);
    });
  }

  @override
  Future<void> deleteInsumo(int id) {
    return ErrorMapper.guard(() => _datasource.deleteInsumo(id));
  }
}
