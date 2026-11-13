import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/mesa_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/mesa_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/mesa.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/estado_mesa.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/mesa_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/mesa_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/mesa_model.dart';

class MesaRepositoryImpl implements MesaRepository {
  const MesaRepositoryImpl(this._datasource);

  final MesaDatasource _datasource;

  @override
  Future<PageResult<Mesa>> getMesas({int page = 0, int size = 100}) =>
      ErrorMapper.guard(
        () async => (await _datasource.getMesas(
          page: page,
          size: size,
        )).map(MesaMapper.toEntity),
      );

  @override
  Future<Mesa> getMesa(int id) => ErrorMapper.guard(
    () async => MesaMapper.toEntity(await _datasource.getMesa(id)),
  );

  @override
  Future<Mesa> createMesa(MesaDraft draft) => ErrorMapper.guard(
    () async => MesaMapper.toEntity(
      await _datasource.createMesa(MesaRequest.fromDraft(draft)),
    ),
  );

  @override
  Future<Mesa> updateMesa(int id, MesaDraft draft) => ErrorMapper.guard(
    () async => MesaMapper.toEntity(
      await _datasource.updateMesa(id, MesaRequest.fromDraft(draft)),
    ),
  );

  @override
  Future<void> deleteMesa(int id) =>
      ErrorMapper.guard(() => _datasource.deleteMesa(id));

  @override
  Future<Mesa> updateEstado(int id, EstadoMesa estado) => ErrorMapper.guard(
    () async => MesaMapper.toEntity(await _datasource.updateEstado(id, estado)),
  );
}
