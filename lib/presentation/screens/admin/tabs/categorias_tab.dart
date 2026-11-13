import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_crud_host.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_form_modal.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_row_actions.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_table_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/responsive_data_table.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_dropdown_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/categorias_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

class CategoriasTab extends StatelessWidget {
  const CategoriasTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriasCubit>(
      create: (_) => getIt<CategoriasCubit>()..load(),
      child: CategoriasView(createRequests: createRequests),
    );
  }
}

class CategoriasView extends StatelessWidget {
  const CategoriasView({super.key, required this.createRequests});

  final Stream<void> createRequests;

  Future<void> _openForm(
    BuildContext context, {
    CategoriaPlato? categoria,
  }) async {
    final cubit = context.read<CategoriasCubit>();
    final form = CategoriaFormController(cubit.draftFor(categoria));
    await showAdminFormModal<CategoriaPlato>(
      context: context,
      cubit: cubit,
      title: categoria == null ? 'Nueva Categoría' : 'Editar Categoría',
      submitLabel: 'Guardar Categoría',
      body: CategoriaFormBody(form: form),
      onSubmit: () => cubit.saveCategoria(form.toDraft(), id: categoria?.id),
    );
  }

  Future<void> _delete(BuildContext context, CategoriaPlato categoria) async {
    final cubit = context.read<CategoriasCubit>();
    final confirmed = await confirmAdminDelete(
      context,
      '¿Eliminar la categoría "${categoria.nombre}"?',
    );
    if (confirmed && !cubit.isClosed) await cubit.deleteCategoria(categoria);
  }

  @override
  Widget build(BuildContext context) {
    return AdminCrudHost<CategoriasCubit, CategoriaPlato>(
      createRequests: createRequests,
      onCreate: (context) => _openForm(context),
      builder: (context, state) => AdminTableCard<CategoriaPlato>(
        title: 'Categorías del Menú',
        countLabel: '${state.items.length} registradas',
        emptyMessage: 'No hay categorías registradas',
        loading: state.loading,
        rows: state.items,
        columns: [
          ResponsiveColumn(
            label: 'ID',
            cellBuilder: (_, categoria) => Text(
              '#${categoria.id}',
              style: AppTextStyles.mono.copyWith(color: AppColors.gray400),
            ),
          ),
          ResponsiveColumn(
            label: 'Nombre',
            cellBuilder: (_, categoria) => Text(
              categoria.nombre,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Área de Impresión',
            cellBuilder: (_, categoria) =>
                _AreaChip(area: categoria.areaImpresion),
          ),
          ResponsiveColumn(
            label: 'Orden Visual',
            cellBuilder: (_, categoria) => Text(
              _orden(categoria.ordenVisual),
              style: AppTextStyles.xs.copyWith(color: AppColors.gray600),
            ),
          ),
          ResponsiveColumn(
            label: 'Acciones',
            alignEnd: true,
            cellBuilder: (context, categoria) => AdminRowActions(
              onEdit: () => _openForm(context, categoria: categoria),
              onDelete: () => _delete(context, categoria),
            ),
          ),
        ],
      ),
    );
  }

  static String _orden(int? orden) =>
      orden == null || orden == 0 ? '-' : '$orden';
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({required this.area});

  final AreaImpresion area;

  @override
  Widget build(BuildContext context) {
    final cocina = area == AreaImpresion.cocina;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cocina ? AppColors.amber100 : AppColors.blue100,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        area.toJson(),
        style: AppTextStyles.text11.copyWith(
          fontWeight: FontWeight.w600,
          color: cocina ? AppColors.amber800 : AppColors.blue800,
        ),
      ),
    );
  }
}

class CategoriaFormController extends ChangeNotifier {
  CategoriaFormController(CategoriaPlatoDraft draft)
    : nombre = TextEditingController(text: draft.nombre),
      ordenVisual = TextEditingController(
        text: draft.ordenVisual?.toString() ?? '',
      ),
      _areaImpresion = draft.areaImpresion;

  final TextEditingController nombre;
  final TextEditingController ordenVisual;
  AreaImpresion _areaImpresion;

  AreaImpresion get areaImpresion => _areaImpresion;

  set areaImpresion(AreaImpresion value) {
    _areaImpresion = value;
    notifyListeners();
  }

  CategoriaPlatoDraft toDraft() => CategoriaPlatoDraft(
    nombre: nombre.text,
    areaImpresion: _areaImpresion,
    ordenVisual: int.tryParse(ordenVisual.text.trim()) ?? 0,
  );

  @override
  void dispose() {
    nombre.dispose();
    ordenVisual.dispose();
    super.dispose();
  }
}

class CategoriaFormBody extends StatefulWidget {
  const CategoriaFormBody({super.key, required this.form});

  final CategoriaFormController form;

  @override
  State<CategoriaFormBody> createState() => _CategoriaFormBodyState();
}

class _CategoriaFormBodyState extends State<CategoriaFormBody> {
  CategoriaFormController get form => widget.form;

  @override
  void dispose() {
    widget.form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            key: const ValueKey('categoria.nombre'),
            label: 'Nombre de la Categoría',
            required: true,
            hint: 'Ej: Platos Fuertes, Bebidas, Postres',
            controller: form.nombre,
          ),
          AppSpacing.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppDropdownField<AreaImpresion>(
                  key: const ValueKey('categoria.area'),
                  label: 'Área de Impresión',
                  required: true,
                  value: form.areaImpresion,
                  onChanged: (value) {
                    if (value != null) form.areaImpresion = value;
                  },
                  items: [
                    for (final area in AreaImpresion.values)
                      DropdownMenuItem(value: area, child: Text(area.toJson())),
                  ],
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: AppTextField(
                  key: const ValueKey('categoria.orden'),
                  label: 'Orden Visual',
                  controller: form.ordenVisual,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
