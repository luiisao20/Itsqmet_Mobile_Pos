import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_changes.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_crud_cubit.dart';

class AdminUsuariosCubit extends AdminCrudCubit<Usuario> {
  AdminUsuariosCubit({
    required UsuarioRepository usuarioRepository,
    required AdminChanges changes,
  }) : _usuarios = usuarioRepository,
       super(changes);

  static const int pageSize = 100;
  static const int minPasswordLength = 4;
  static const String requiredMessage =
      'Completa los campos obligatorios del usuario';
  static const String passwordMessage =
      'La contraseña temporal debe tener al menos 4 caracteres';
  static const String saveFallback = 'Error al guardar personal';
  static const String toggleFallback = 'Error al cambiar estado';
  static const String deleteFallback = 'Error al eliminar usuario';

  final UsuarioRepository _usuarios;

  @override
  Future<List<Usuario>> fetch() async =>
      (await _usuarios.getUsuarios(page: 0, size: pageSize)).content;

  UsuarioDraft draftFor(Usuario? usuario) {
    if (usuario == null) {
      return const UsuarioDraft(
        nombre: '',
        apellido: '',
        cedula: '',
        email: '',
        password: '',
        rol: Rol.mesero,
        activo: true,
      );
    }
    return UsuarioDraft(
      nombre: usuario.nombre,
      apellido: usuario.apellido,
      cedula: usuario.cedula,
      email: usuario.email,
      password: '',
      rol: usuario.rol,
      activo: usuario.activo,
    );
  }

  Future<bool> saveUsuario(UsuarioDraft draft, {String? uuid}) {
    final nombre = draft.nombre.trim();
    final apellido = draft.apellido.trim();
    final cedula = draft.cedula.trim();
    final email = draft.email.trim();
    if (nombre.isEmpty || apellido.isEmpty || email.isEmpty || cedula.isEmpty) {
      reject(requiredMessage);
      return Future.value(false);
    }
    final password = draft.password ?? '';
    if (uuid == null && password.length < minPasswordLength) {
      reject(passwordMessage);
      return Future.value(false);
    }
    final trimmedPassword = password.trim();
    final request = UsuarioDraft(
      nombre: nombre,
      apellido: apellido,
      cedula: cedula,
      email: email,
      password: trimmedPassword.isEmpty ? null : trimmedPassword,
      rol: draft.rol,
      activo: draft.activo,
    );
    return save(
      () => uuid == null
          ? _usuarios.createUsuario(request)
          : _usuarios.updateUsuario(uuid, request),
      fallback: saveFallback,
    );
  }

  Future<bool> toggleActivo(Usuario usuario) {
    final request = UsuarioDraft(
      nombre: usuario.nombre,
      apellido: usuario.apellido,
      cedula: usuario.cedula,
      email: usuario.email,
      rol: usuario.rol,
      activo: !usuario.activo,
    );
    return run(
      () => _usuarios.updateUsuario(usuario.uuid, request),
      fallback: toggleFallback,
    );
  }

  Future<bool> deleteUsuario(Usuario usuario) => run(
    () => _usuarios.deleteUsuario(usuario.uuid),
    fallback: deleteFallback,
  );
}
