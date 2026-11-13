import 'package:itsqmet_mobile_pos/data/domain/entities/drafts/usuario_draft.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/usuario.dart';

abstract interface class UsuarioRepository {
  Future<PageResult<Usuario>> getUsuarios({int page = 0, int size = 100});

  Future<Usuario> getUsuario(String uuid);

  Future<Usuario> createUsuario(UsuarioDraft draft);

  Future<Usuario> updateUsuario(String uuid, UsuarioDraft draft);

  Future<void> deleteUsuario(String uuid);
}
