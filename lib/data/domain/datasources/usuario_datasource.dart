import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/usuario_model.dart';

abstract interface class UsuarioDatasource {
  Future<PageResult<UsuarioModel>> getUsuarios({int page = 0, int size = 100});

  Future<UsuarioModel> getUsuario(String uuid);

  Future<UsuarioModel> createUsuario(UsuarioRequest request);

  Future<UsuarioModel> updateUsuario(String uuid, UsuarioRequest request);

  Future<void> deleteUsuario(String uuid);
}
