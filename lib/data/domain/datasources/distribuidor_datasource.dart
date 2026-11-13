import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/distribuidor_model.dart';

abstract interface class DistribuidorDatasource {
  Future<PageResult<DistribuidorModel>> getDistribuidores({
    int page = 0,
    int size = 100,
  });

  Future<DistribuidorModel> createDistribuidor(DistribuidorRequest request);

  Future<DistribuidorModel> updateDistribuidor(
    int id,
    DistribuidorRequest request,
  );

  Future<void> deleteDistribuidor(int id);
}
