import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_changes.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_crud_cubit.dart';

class DistribuidoresCubit extends AdminCrudCubit<Distribuidor> {
  DistribuidoresCubit({
    required DistribuidorRepository distribuidorRepository,
    required AdminChanges changes,
  }) : _distribuidores = distribuidorRepository,
       super(changes);

  static const int pageSize = 100;
  static const String newCategoria = 'Alimentos';
  static const String fallbackCategoria = 'General';
  static const String invalidMessage = 'RUC y Razón Social son obligatorios';
  static const String saveFallback = 'Error al guardar distribuidor';
  static const String deleteFallback = 'Error al eliminar distribuidor';

  final DistribuidorRepository _distribuidores;

  @override
  Future<List<Distribuidor>> fetch() async {
    final page = await _distribuidores.getDistribuidores(
      page: 0,
      size: pageSize,
    );
    return page.content;
  }

  DistribuidorDraft draftFor(Distribuidor? distribuidor) {
    if (distribuidor == null) {
      return const DistribuidorDraft(
        ruc: '',
        razonSocial: '',
        nombreContacto: '',
        telefono: '',
        email: '',
        direccion: '',
        categoriaProveedor: newCategoria,
      );
    }
    return DistribuidorDraft(
      ruc: distribuidor.ruc,
      razonSocial: distribuidor.razonSocial,
      nombreContacto: _orEmpty(distribuidor.nombreContacto),
      telefono: _orEmpty(distribuidor.telefono),
      email: _orEmpty(distribuidor.email),
      direccion: _orEmpty(distribuidor.direccion),
      categoriaProveedor: _orEmpty(distribuidor.categoriaProveedor).isEmpty
          ? fallbackCategoria
          : distribuidor.categoriaProveedor,
    );
  }

  Future<bool> saveDistribuidor(DistribuidorDraft draft, {int? id}) {
    final ruc = draft.ruc.trim();
    final razonSocial = draft.razonSocial.trim();
    if (ruc.isEmpty || razonSocial.isEmpty) {
      reject(invalidMessage);
      return Future.value(false);
    }
    final request = DistribuidorDraft(
      ruc: ruc,
      razonSocial: razonSocial,
      nombreContacto: _optional(draft.nombreContacto),
      telefono: _optional(draft.telefono),
      email: _optional(draft.email),
      direccion: _optional(draft.direccion),
      categoriaProveedor: _optional(draft.categoriaProveedor),
    );
    return save(
      () => id == null
          ? _distribuidores.createDistribuidor(request)
          : _distribuidores.updateDistribuidor(id, request),
      fallback: saveFallback,
    );
  }

  Future<bool> deleteDistribuidor(Distribuidor distribuidor) => run(
    () => _distribuidores.deleteDistribuidor(distribuidor.id),
    fallback: deleteFallback,
  );

  static String _orEmpty(String? value) => value ?? '';

  static String? _optional(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
