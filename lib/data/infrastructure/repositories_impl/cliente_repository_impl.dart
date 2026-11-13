import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/cliente_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/cliente.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/cliente_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/cliente_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/cliente_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/cliente_model.dart';

class ClienteRepositoryImpl implements ClienteRepository {
  ClienteRepositoryImpl(this._datasource);

  final ClienteDatasource _datasource;

  @override
  Future<PageResult<Cliente>> getClientes({int page = 0, int size = 100}) {
    return ErrorMapper.guard(() async {
      final result = await _datasource.getClientes(page: page, size: size);
      return result.map(ClienteMapper.toEntity);
    });
  }

  @override
  Future<Cliente> getCliente(String uuid) {
    return ErrorMapper.guard(
      () async => ClienteMapper.toEntity(await _datasource.getCliente(uuid)),
    );
  }

  @override
  Future<Cliente> getByIdentificacion(String identificacion) {
    return ErrorMapper.guard(() async {
      final model = await _datasource.getByIdentificacion(identificacion);
      return ClienteMapper.toEntity(model);
    });
  }

  @override
  Future<PageResult<Cliente>> searchClientes(
    String filtro, {
    int page = 0,
    int size = 50,
  }) {
    return ErrorMapper.guard(() async {
      final result = await _datasource.searchClientes(
        filtro,
        page: page,
        size: size,
      );
      return result.map(ClienteMapper.toEntity);
    });
  }

  @override
  Future<Cliente> createCliente(ClienteDraft draft) {
    return ErrorMapper.guard(() async {
      final model = await _datasource.createCliente(
        ClienteRequest.fromDraft(draft),
      );
      return ClienteMapper.toEntity(model);
    });
  }

  @override
  Future<Cliente> updateCliente(String uuid, ClienteDraft draft) {
    return ErrorMapper.guard(() async {
      final model = await _datasource.updateCliente(
        uuid,
        ClienteRequest.fromDraft(draft),
      );
      return ClienteMapper.toEntity(model);
    });
  }

  @override
  Future<void> deleteCliente(String uuid) {
    return ErrorMapper.guard(() => _datasource.deleteCliente(uuid));
  }
}
