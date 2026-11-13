import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_changes.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_crud_cubit.dart';

class AdminClientesCubit extends AdminCrudCubit<Cliente> {
  AdminClientesCubit({
    required ClienteRepository clienteRepository,
    required AdminChanges changes,
  }) : _clientes = clienteRepository,
       super(changes);

  static const int pageSize = 100;
  static const String invalidMessage =
      'Identificación y Razón Social son obligatorias';
  static const String saveFallback = 'Error al guardar cliente';
  static const String deleteFallback = 'Error al eliminar cliente';

  final ClienteRepository _clientes;

  @override
  Future<List<Cliente>> fetch() async {
    final page = await _clientes.getClientes(page: 0, size: pageSize);
    return page.content;
  }

  ClienteDraft draftFor(Cliente? cliente) {
    if (cliente == null) {
      return const ClienteDraft(
        tipoIdentificacion: TipoIdentificacion.cedula,
        identificacion: '',
        razonSocial: '',
        direccion: '',
        telefono: '',
        email: '',
      );
    }
    return ClienteDraft(
      tipoIdentificacion: cliente.tipoIdentificacion,
      identificacion: cliente.identificacion,
      razonSocial: cliente.razonSocial,
      direccion: cliente.direccion ?? '',
      telefono: cliente.telefono ?? '',
      email: cliente.email ?? '',
    );
  }

  Future<bool> saveCliente(ClienteDraft draft, {String? uuid}) {
    final identificacion = draft.identificacion.trim();
    final razonSocial = draft.razonSocial.trim();
    if (identificacion.isEmpty || razonSocial.isEmpty) {
      reject(invalidMessage);
      return Future.value(false);
    }
    final request = ClienteDraft(
      tipoIdentificacion: draft.tipoIdentificacion,
      identificacion: identificacion,
      razonSocial: razonSocial,
      direccion: _optional(draft.direccion),
      telefono: _optional(draft.telefono),
      email: _optional(draft.email),
    );
    return save(
      () => uuid == null
          ? _clientes.createCliente(request)
          : _clientes.updateCliente(uuid, request),
      fallback: saveFallback,
    );
  }

  Future<bool> deleteCliente(Cliente cliente) => run(
    () => _clientes.deleteCliente(cliente.uuid),
    fallback: deleteFallback,
  );

  static String? _optional(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
