import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_crud_host.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_form_modal.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_row_actions.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_table_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/app_badge.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/responsive_data_table.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_dropdown_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/insumos_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

String _quantity(double value) {
  if (value.isFinite && value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

double _parse(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.')) ?? 0;

bool _isLowStock(Insumo insumo) => insumo.stockActual <= insumo.stockMinimo;

class InsumosTab extends StatelessWidget {
  const InsumosTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InsumosCubit>(
      create: (_) => getIt<InsumosCubit>()..load(),
      child: InsumosView(createRequests: createRequests),
    );
  }
}

class InsumosView extends StatelessWidget {
  const InsumosView({super.key, required this.createRequests});

  final Stream<void> createRequests;

  Future<void> _openForm(BuildContext context, {Insumo? insumo}) async {
    final cubit = context.read<InsumosCubit>();
    final form = InsumoFormController(cubit.draftFor(insumo));
    await showAdminFormModal<Insumo>(
      context: context,
      cubit: cubit,
      title: insumo == null ? 'Nuevo Insumo' : 'Editar Insumo',
      submitLabel: 'Guardar Insumo',
      body: InsumoFormBody(form: form),
      onSubmit: () => cubit.saveInsumo(form.toDraft(), id: insumo?.id),
    );
  }

  Future<void> _delete(BuildContext context, Insumo insumo) async {
    final cubit = context.read<InsumosCubit>();
    final confirmed = await confirmAdminDelete(
      context,
      '¿Eliminar el insumo "${insumo.nombre}"?',
    );
    if (confirmed && !cubit.isClosed) await cubit.deleteInsumo(insumo);
  }

  @override
  Widget build(BuildContext context) {
    return AdminCrudHost<InsumosCubit, Insumo>(
      createRequests: createRequests,
      onCreate: (context) => _openForm(context),
      builder: (context, state) => AdminTableCard<Insumo>(
        title: 'Control de Stock e Insumos',
        countLabel: '${state.items.length} insumos registrados',
        emptyMessage: 'No hay insumos registrados',
        loading: state.loading,
        rows: state.items,
        columns: [
          ResponsiveColumn(
            label: 'Insumo',
            cellBuilder: (_, insumo) => Text(
              insumo.nombre,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Unidad',
            cellBuilder: (_, insumo) => Text(
              insumo.unidadMedida.toJson(),
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Stock Actual',
            cellBuilder: (_, insumo) {
              final low = _isLowStock(insumo);
              return Text(
                _quantity(insumo.stockActual),
                style: AppTextStyles.mono.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: low ? FontWeight.w700 : FontWeight.w400,
                  color: low ? AppColors.red600 : AppColors.gray900,
                ),
              );
            },
          ),
          ResponsiveColumn(
            label: 'Stock Mínimo',
            cellBuilder: (_, insumo) =>
                Text(_quantity(insumo.stockMinimo), style: AppTextStyles.mono),
          ),
          ResponsiveColumn(
            label: 'Costo Promedio',
            cellBuilder: (_, insumo) => Text(
              CurrencyFormat.format(insumo.costoPromedio),
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.emerald800,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Alerta',
            cellBuilder: (_, insumo) => _isLowStock(insumo)
                ? const AppBadge(
                    label: 'Stock Bajo',
                    variant: BadgeVariant.danger,
                  )
                : const AppBadge(
                    label: 'Normal',
                    variant: BadgeVariant.success,
                  ),
          ),
          ResponsiveColumn(
            label: 'Acciones',
            alignEnd: true,
            cellBuilder: (context, insumo) => AdminRowActions(
              onEdit: () => _openForm(context, insumo: insumo),
              onDelete: () => _delete(context, insumo),
            ),
          ),
        ],
      ),
    );
  }
}

class InsumoFormController extends ChangeNotifier {
  InsumoFormController(InsumoDraft draft)
    : nombre = TextEditingController(text: draft.nombre),
      stockActual = TextEditingController(text: _quantity(draft.stockActual)),
      stockMinimo = TextEditingController(text: _quantity(draft.stockMinimo)),
      costoPromedio = TextEditingController(
        text: CurrencyFormat.plain(draft.costoPromedio),
      ),
      _unidadMedida = draft.unidadMedida;

  final TextEditingController nombre;
  final TextEditingController stockActual;
  final TextEditingController stockMinimo;
  final TextEditingController costoPromedio;
  UnidadMedida _unidadMedida;

  UnidadMedida get unidadMedida => _unidadMedida;

  set unidadMedida(UnidadMedida value) {
    _unidadMedida = value;
    notifyListeners();
  }

  InsumoDraft toDraft() => InsumoDraft(
    nombre: nombre.text,
    unidadMedida: _unidadMedida,
    stockActual: _parse(stockActual.text),
    stockMinimo: _parse(stockMinimo.text),
    costoPromedio: _parse(costoPromedio.text),
  );

  @override
  void dispose() {
    nombre.dispose();
    stockActual.dispose();
    stockMinimo.dispose();
    costoPromedio.dispose();
    super.dispose();
  }
}

class InsumoFormBody extends StatefulWidget {
  const InsumoFormBody({super.key, required this.form});

  final InsumoFormController form;

  @override
  State<InsumoFormBody> createState() => _InsumoFormBodyState();
}

class _InsumoFormBodyState extends State<InsumoFormBody> {
  InsumoFormController get form => widget.form;

  static const _decimal = TextInputType.numberWithOptions(
    decimal: true,
    signed: true,
  );

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
            key: const ValueKey('insumo.nombre'),
            label: 'Nombre del Insumo',
            required: true,
            hint: 'Ej: Tomate Riñón, Carne de Res, Aceite',
            controller: form.nombre,
          ),
          AppSpacing.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppDropdownField<UnidadMedida>(
                  label: 'Unidad de Medida',
                  required: true,
                  value: form.unidadMedida,
                  onChanged: (value) {
                    if (value != null) form.unidadMedida = value;
                  },
                  items: [
                    for (final unidad in UnidadMedida.values)
                      DropdownMenuItem(
                        value: unidad,
                        child: Text(
                          unidad.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: AppTextField(
                  key: const ValueKey('insumo.costo'),
                  label: 'Costo Promedio (\$)',
                  required: true,
                  controller: form.costoPromedio,
                  keyboardType: _decimal,
                ),
              ),
            ],
          ),
          AppSpacing.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  key: const ValueKey('insumo.stockActual'),
                  label: 'Stock Actual',
                  required: true,
                  controller: form.stockActual,
                  keyboardType: _decimal,
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: AppTextField(
                  key: const ValueKey('insumo.stockMinimo'),
                  label: 'Stock Mínimo',
                  required: true,
                  controller: form.stockMinimo,
                  keyboardType: _decimal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
