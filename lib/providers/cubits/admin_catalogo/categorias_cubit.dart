import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_changes.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_crud_cubit.dart';

class CategoriasCubit extends AdminCrudCubit<CategoriaPlato> {
  CategoriasCubit({
    required CatalogoRepository catalogoRepository,
    required AdminChanges changes,
  }) : _catalogo = catalogoRepository,
       super(changes);

  static const String invalidMessage = 'Ingresa el nombre de la categoría';
  static const String saveFallback = 'Error al guardar categoría';
  static const String deleteFallback = 'Error al eliminar categoría';

  final CatalogoRepository _catalogo;

  @override
  Future<List<CategoriaPlato>> fetch() => _catalogo.getCategorias();

  CategoriaPlatoDraft draftFor(CategoriaPlato? categoria) {
    if (categoria == null) {
      return CategoriaPlatoDraft(
        nombre: '',
        areaImpresion: AreaImpresion.cocina,
        ordenVisual: state.items.length + 1,
      );
    }
    final orden = categoria.ordenVisual;
    return CategoriaPlatoDraft(
      nombre: categoria.nombre,
      areaImpresion: categoria.areaImpresion,
      ordenVisual: orden == null || orden == 0 ? 1 : orden,
    );
  }

  Future<bool> saveCategoria(CategoriaPlatoDraft draft, {int? id}) {
    final nombre = draft.nombre.trim();
    if (nombre.isEmpty) {
      reject(invalidMessage);
      return Future.value(false);
    }
    final request = CategoriaPlatoDraft(
      nombre: nombre,
      areaImpresion: draft.areaImpresion,
      ordenVisual: draft.ordenVisual,
    );
    return save(
      () => id == null
          ? _catalogo.createCategoria(request)
          : _catalogo.updateCategoria(id, request),
      fallback: saveFallback,
    );
  }

  Future<bool> deleteCategoria(CategoriaPlato categoria) => run(
    () => _catalogo.deleteCategoria(categoria.id),
    fallback: deleteFallback,
  );
}
