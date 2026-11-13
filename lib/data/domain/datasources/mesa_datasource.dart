import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/estado_mesa.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/mesa_model.dart';

abstract interface class MesaDatasource {
  Future<PageResult<MesaModel>> getMesas({int page = 0, int size = 100});

  Future<MesaModel> getMesa(int id);

  Future<MesaModel> createMesa(MesaRequest request);

  Future<MesaModel> updateMesa(int id, MesaRequest request);

  Future<void> deleteMesa(int id);

  Future<MesaModel> updateEstado(int id, EstadoMesa estado);
}
