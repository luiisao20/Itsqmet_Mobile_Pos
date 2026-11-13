import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_changes.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_crud_cubit.dart';

class InsumosCubit extends AdminCrudCubit<Insumo> {
  InsumosCubit({
    required InsumoRepository insumoRepository,
    required AdminChanges changes,
  }) : _insumos = insumoRepository,
       super(changes);

  static const int pageSize = 100;
  static const String invalidMessage = 'Ingresa un nombre y cantidades válidas';
  static const String saveFallback = 'Error al guardar insumo';
  static const String deleteFallback = 'Error al eliminar insumo';

  final InsumoRepository _insumos;

  @override
  Future<List<Insumo>> fetch() async =>
      (await _insumos.getInsumos(page: 0, size: pageSize)).content;

  InsumoDraft draftFor(Insumo? insumo) {
    if (insumo == null) {
      return const InsumoDraft(
        nombre: '',
        unidadMedida: UnidadMedida.unidad,
        stockActual: 10,
        stockMinimo: 5,
        costoPromedio: 1.0,
      );
    }
    return InsumoDraft(
      nombre: insumo.nombre,
      unidadMedida: insumo.unidadMedida,
      stockActual: insumo.stockActual,
      stockMinimo: insumo.stockMinimo,
      costoPromedio: insumo.costoPromedio,
    );
  }

  Future<bool> saveInsumo(InsumoDraft draft, {int? id}) {
    final nombre = draft.nombre.trim();
    if (nombre.isEmpty || draft.stockActual < 0 || draft.stockMinimo < 0) {
      reject(invalidMessage);
      return Future.value(false);
    }
    final request = InsumoDraft(
      nombre: nombre,
      unidadMedida: draft.unidadMedida,
      stockActual: draft.stockActual,
      stockMinimo: draft.stockMinimo,
      costoPromedio: draft.costoPromedio,
    );
    return save(
      () => id == null
          ? _insumos.createInsumo(request)
          : _insumos.updateInsumo(id, request),
      fallback: saveFallback,
    );
  }

  Future<bool> deleteInsumo(Insumo insumo) =>
      run(() => _insumos.deleteInsumo(insumo.id), fallback: deleteFallback);
}
