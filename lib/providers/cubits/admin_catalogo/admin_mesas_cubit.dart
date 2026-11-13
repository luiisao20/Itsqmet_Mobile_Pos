import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_changes.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_crud_cubit.dart';

class AdminMesasCubit extends AdminCrudCubit<Mesa> {
  AdminMesasCubit({
    required MesaRepository mesaRepository,
    required AdminChanges changes,
  }) : _mesas = mesaRepository,
       super(changes);

  static const int pageSize = 100;
  static const int defaultCapacidad = 4;
  static const String defaultUbicacion = 'Salón Principal';
  static const String invalidMessage =
      'Número de mesa y capacidad deben ser mayores a 0';
  static const String saveFallback = 'Error al guardar mesa';
  static const String deleteFallback = 'Error al eliminar mesa';

  final MesaRepository _mesas;

  @override
  Future<List<Mesa>> fetch() async {
    final result = await _mesas.getMesas(page: 0, size: pageSize);
    return result.content;
  }

  MesaDraft draftFor(Mesa? mesa) {
    if (mesa == null) {
      return MesaDraft(
        numeroMesa: _nextNumero(),
        capacidad: defaultCapacidad,
        ubicacion: defaultUbicacion,
        estado: EstadoMesa.libre,
      );
    }
    final ubicacion = mesa.ubicacion ?? '';
    return MesaDraft(
      numeroMesa: mesa.numeroMesa,
      capacidad: mesa.capacidad,
      ubicacion: ubicacion.isEmpty ? defaultUbicacion : ubicacion,
      estado: mesa.estado,
    );
  }

  Future<bool> saveMesa(MesaDraft draft, {int? id}) {
    if (draft.numeroMesa <= 0 || draft.capacidad <= 0) {
      reject(invalidMessage);
      return Future.value(false);
    }
    final request = MesaDraft(
      numeroMesa: draft.numeroMesa,
      capacidad: draft.capacidad,
      ubicacion: _optional(draft.ubicacion),
      estado: draft.estado,
    );
    return save(
      () => id == null
          ? _mesas.createMesa(request)
          : _mesas.updateMesa(id, request),
      fallback: saveFallback,
    );
  }

  Future<bool> deleteMesa(Mesa mesa) =>
      run(() => _mesas.deleteMesa(mesa.id), fallback: deleteFallback);

  int _nextNumero() {
    final items = state.items;
    if (items.isEmpty) return 1;
    return items.map((m) => m.numeroMesa).reduce((a, b) => a > b ? a : b) + 1;
  }

  static String? _optional(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
