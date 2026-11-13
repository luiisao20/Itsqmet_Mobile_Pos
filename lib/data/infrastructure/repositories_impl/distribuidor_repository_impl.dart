import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/distribuidor_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/distribuidor.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/distribuidor_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/distribuidor_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/distribuidor_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/distribuidor_model.dart';

class DistribuidorRepositoryImpl implements DistribuidorRepository {
  DistribuidorRepositoryImpl(this._datasource);

  final DistribuidorDatasource _datasource;

  @override
  Future<PageResult<Distribuidor>> getDistribuidores({
    int page = 0,
    int size = 100,
  }) {
    return ErrorMapper.guard(() async {
      final result = await _datasource.getDistribuidores(
        page: page,
        size: size,
      );
      return result.map(DistribuidorMapper.toEntity);
    });
  }

  @override
  Future<Distribuidor> createDistribuidor(DistribuidorDraft draft) {
    return ErrorMapper.guard(() async {
      final model = await _datasource.createDistribuidor(
        DistribuidorRequest.fromDraft(draft),
      );
      return DistribuidorMapper.toEntity(model);
    });
  }

  @override
  Future<Distribuidor> updateDistribuidor(int id, DistribuidorDraft draft) {
    return ErrorMapper.guard(() async {
      final model = await _datasource.updateDistribuidor(
        id,
        DistribuidorRequest.fromDraft(draft),
      );
      return DistribuidorMapper.toEntity(model);
    });
  }

  @override
  Future<void> deleteDistribuidor(int id) {
    return ErrorMapper.guard(() => _datasource.deleteDistribuidor(id));
  }
}
