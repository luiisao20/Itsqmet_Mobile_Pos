import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_crud_host.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_form_modal.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_row_actions.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_table_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/status_badges.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/responsive_data_table.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_dropdown_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_catalogo/admin_mesas_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

class MesasTab extends StatelessWidget {
  const MesasTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminMesasCubit>(
      create: (_) => getIt<AdminMesasCubit>()..load(),
      child: AdminMesasView(createRequests: createRequests),
    );
  }
}

class AdminMesasView extends StatelessWidget {
  const AdminMesasView({super.key, required this.createRequests});

  final Stream<void> createRequests;

  Future<void> _openForm(BuildContext context, {Mesa? mesa}) async {
    final cubit = context.read<AdminMesasCubit>();
    final form = MesaFormController(cubit.draftFor(mesa));
    await showAdminFormModal<Mesa>(
      context: context,
      cubit: cubit,
      title: mesa == null ? 'Nueva Mesa' : 'Editar Mesa',
      submitLabel: 'Guardar Mesa',
      body: MesaFormBody(form: form),
      onSubmit: () => cubit.saveMesa(form.toDraft(), id: mesa?.id),
    );
  }

  Future<void> _delete(BuildContext context, Mesa mesa) async {
    final cubit = context.read<AdminMesasCubit>();
    final confirmed = await confirmAdminDelete(
      context,
      '¿Eliminar la Mesa #${mesa.numeroMesa}?',
    );
    if (confirmed && !cubit.isClosed) await cubit.deleteMesa(mesa);
  }

  @override
  Widget build(BuildContext context) {
    return AdminCrudHost<AdminMesasCubit, Mesa>(
      createRequests: createRequests,
      onCreate: (context) => _openForm(context),
      builder: (context, state) => AdminTableCard<Mesa>(
        title: 'Distribución de Mesas del Salón',
        countLabel: '${state.items.length} mesas configuradas',
        emptyMessage: 'No hay mesas registradas',
        loading: state.loading,
        rows: state.items,
        columns: [
          ResponsiveColumn(
            label: 'Mesa #',
            cellBuilder: (_, mesa) => Text(
              'Mesa ${mesa.numeroMesa}',
              style: AppTextStyles.sm.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.gray900,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Ubicación',
            cellBuilder: (_, mesa) => Text(
              _ubicacion(mesa.ubicacion),
              style: AppTextStyles.xs.copyWith(color: AppColors.gray600),
            ),
          ),
          ResponsiveColumn(
            label: 'Capacidad',
            cellBuilder: (_, mesa) => Text(
              '${mesa.capacidad} personas',
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Estado',
            cellBuilder: (_, mesa) =>
                StatusBadge(StatusBadges.mesa(mesa.estado.toJson())),
          ),
          ResponsiveColumn(
            label: 'Acciones',
            alignEnd: true,
            cellBuilder: (context, mesa) => AdminRowActions(
              onEdit: () => _openForm(context, mesa: mesa),
              onDelete: () => _delete(context, mesa),
            ),
          ),
        ],
      ),
    );
  }

  static String _ubicacion(String? value) =>
      value == null || value.isEmpty ? 'General' : value;
}

class MesaFormController extends ChangeNotifier {
  MesaFormController(MesaDraft draft)
    : numero = TextEditingController(text: '${draft.numeroMesa}'),
      capacidad = TextEditingController(text: '${draft.capacidad}'),
      ubicacion = TextEditingController(text: draft.ubicacion ?? ''),
      _estado = draft.estado ?? EstadoMesa.libre;

  final TextEditingController numero;
  final TextEditingController capacidad;
  final TextEditingController ubicacion;
  EstadoMesa _estado;

  EstadoMesa get estado => _estado;

  set estado(EstadoMesa value) {
    _estado = value;
    notifyListeners();
  }

  MesaDraft toDraft() => MesaDraft(
    numeroMesa: _parse(numero.text),
    capacidad: _parse(capacidad.text),
    ubicacion: ubicacion.text,
    estado: _estado,
  );

  static int _parse(String text) => int.tryParse(text.trim()) ?? 0;

  @override
  void dispose() {
    numero.dispose();
    capacidad.dispose();
    ubicacion.dispose();
    super.dispose();
  }
}

class MesaFormBody extends StatefulWidget {
  const MesaFormBody({super.key, required this.form});

  final MesaFormController form;

  @override
  State<MesaFormBody> createState() => _MesaFormBodyState();
}

class _MesaFormBodyState extends State<MesaFormBody> {
  MesaFormController get form => widget.form;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  key: const ValueKey('mesa.numero'),
                  label: 'Número de Mesa',
                  required: true,
                  controller: form.numero,
                  keyboardType: TextInputType.number,
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: AppTextField(
                  key: const ValueKey('mesa.capacidad'),
                  label: 'Capacidad (Personas)',
                  required: true,
                  controller: form.capacidad,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          AppSpacing.h16,
          AppTextField(
            key: const ValueKey('mesa.ubicacion'),
            label: 'Ubicación',
            hint: 'Ej: Terraza, Salón Principal, Barra',
            controller: form.ubicacion,
          ),
          AppSpacing.h16,
          AppDropdownField<EstadoMesa>(
            label: 'Estado Inicial',
            value: form.estado,
            onChanged: (value) {
              if (value != null) form.estado = value;
            },
            items: [
              for (final estado in EstadoMesa.values)
                DropdownMenuItem(value: estado, child: Text(estado.toJson())),
            ],
          ),
        ],
      ),
    );
  }
}
