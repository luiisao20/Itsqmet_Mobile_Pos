import 'package:itsqmet_mobile_pos/core/errors/errors.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_changes.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_crud_cubit.dart';

class PlatosCubit extends AdminCrudCubit<Plato> {
  PlatosCubit({
    required CatalogoRepository catalogoRepository,
    required AdminChanges changes,
  }) : _catalogo = catalogoRepository,
       super(changes);

  static const int pageSize = 100;
  static const String invalidMessage = 'Ingresa un nombre y precio válido';
  static const String saveFallback = 'Error al procesar el plato';
  static const String toggleFallback = 'Error al actualizar disponibilidad';
  static const String deleteFallback = 'Error al eliminar plato';

  final CatalogoRepository _catalogo;
  List<CategoriaPlato> _categorias = const [];

  List<CategoriaPlato> get categorias => _categorias;

  @override
  Future<List<Plato>> fetch() async {
    final results = await Future.wait([
      _catalogo.getPlatos(page: 0, size: pageSize),
      _loadCategorias(),
    ]);
    return (results.first as PageResult<Plato>).content;
  }

  Future<void> _loadCategorias() async {
    try {
      _categorias = await _catalogo.getCategorias();
    } on AppException {
      return;
    }
  }

  PlatoDraft draftFor(Plato? plato) {
    if (plato == null) {
      return PlatoDraft(
        idCategoria: _categorias.isEmpty ? 1 : _categorias.first.id,
        nombre: '',
        descripcion: '',
        precioUnitario: 0,
        aplicaIva: true,
        disponible: true,
        urlImagen: '',
      );
    }
    return PlatoDraft(
      idCategoria: plato.idCategoria,
      nombre: plato.nombre,
      descripcion: plato.descripcion ?? '',
      precioUnitario: plato.precioUnitario,
      aplicaIva: plato.aplicaIva,
      disponible: plato.disponible,
      urlImagen: plato.urlImagen ?? '',
    );
  }

  Future<bool> savePlato(PlatoDraft draft, {int? id}) {
    final nombre = draft.nombre.trim();
    if (nombre.isEmpty || draft.precioUnitario <= 0) {
      reject(invalidMessage);
      return Future.value(false);
    }
    final request = PlatoDraft(
      idCategoria: draft.idCategoria,
      nombre: nombre,
      descripcion: _optional(draft.descripcion),
      precioUnitario: draft.precioUnitario,
      aplicaIva: draft.aplicaIva,
      disponible: draft.disponible,
      urlImagen: _optional(draft.urlImagen),
    );
    return save(
      () => id == null
          ? _catalogo.createPlato(request)
          : _catalogo.updatePlato(id, request),
      fallback: saveFallback,
    );
  }

  Future<bool> toggleDisponible(Plato plato) {
    final current = draftFor(plato);
    final request = PlatoDraft(
      idCategoria: current.idCategoria,
      nombre: current.nombre,
      descripcion: _optional(current.descripcion),
      precioUnitario: current.precioUnitario,
      aplicaIva: current.aplicaIva,
      disponible: !plato.disponible,
      urlImagen: _optional(current.urlImagen),
    );
    return run(
      () => _catalogo.updatePlato(plato.id, request),
      fallback: toggleFallback,
    );
  }

  Future<bool> deletePlato(Plato plato) =>
      run(() => _catalogo.deletePlato(plato.id), fallback: deleteFallback);

  static String? _optional(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
