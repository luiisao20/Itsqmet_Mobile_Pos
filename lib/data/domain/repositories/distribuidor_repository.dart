import 'package:itsqmet_mobile_pos/data/domain/entities/distribuidor.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/distribuidor_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';

abstract interface class DistribuidorRepository {
  Future<PageResult<Distribuidor>> getDistribuidores({
    int page = 0,
    int size = 100,
  });

  Future<Distribuidor> createDistribuidor(DistribuidorDraft draft);

  Future<Distribuidor> updateDistribuidor(int id, DistribuidorDraft draft);

  Future<void> deleteDistribuidor(int id);
}
