import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/mesa_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/mesa.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/estado_mesa.dart';

abstract interface class MesaRepository {
  Future<PageResult<Mesa>> getMesas({int page = 0, int size = 100});

  Future<Mesa> getMesa(int id);

  Future<Mesa> createMesa(MesaDraft draft);

  Future<Mesa> updateMesa(int id, MesaDraft draft);

  Future<void> deleteMesa(int id);

  Future<Mesa> updateEstado(int id, EstadoMesa estado);
}
