import 'package:itsqmet_mobile_pos/core/errors/error_mapper.dart';
import 'package:itsqmet_mobile_pos/data/domain/datasources/usuario_datasource.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/usuario_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/usuario.dart';
import 'package:itsqmet_mobile_pos/data/domain/repositories/usuario_repository.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/mappers/usuario_mapper.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/usuario_model.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  UsuarioRepositoryImpl(this._datasource);

  final UsuarioDatasource _datasource;

  @override
  Future<PageResult<Usuario>> getUsuarios({int page = 0, int size = 100}) {
    return ErrorMapper.guard(() async {
      final result = await _datasource.getUsuarios(page: page, size: size);
      return result.map(UsuarioMapper.toEntity);
    });
  }

  @override
  Future<Usuario> getUsuario(String uuid) {
    return ErrorMapper.guard(
      () async => UsuarioMapper.toEntity(await _datasource.getUsuario(uuid)),
    );
  }

  @override
  Future<Usuario> createUsuario(UsuarioDraft draft) {
    return ErrorMapper.guard(() async {
      final model = await _datasource.createUsuario(
        UsuarioRequest.fromDraft(draft),
      );
      return UsuarioMapper.toEntity(model);
    });
  }

  @override
  Future<Usuario> updateUsuario(String uuid, UsuarioDraft draft) {
    return ErrorMapper.guard(() async {
      final model = await _datasource.updateUsuario(
        uuid,
        UsuarioRequest.fromDraft(draft),
      );
      return UsuarioMapper.toEntity(model);
    });
  }

  @override
  Future<void> deleteUsuario(String uuid) {
    return ErrorMapper.guard(() => _datasource.deleteUsuario(uuid));
  }
}
