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
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_clientes_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

const Map<TipoIdentificacion, String> _tipoLabels = {
  TipoIdentificacion.cedula: 'CÉDULA',
  TipoIdentificacion.ruc: 'RUC',
  TipoIdentificacion.pasaporte: 'PASAPORTE',
  TipoIdentificacion.consumidorFinal: 'CONSUMIDOR FINAL',
};

class ClientesTab extends StatelessWidget {
  const ClientesTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminClientesCubit>(
      create: (_) => getIt<AdminClientesCubit>()..load(),
      child: ClientesView(createRequests: createRequests),
    );
  }
}

class ClientesView extends StatelessWidget {
  const ClientesView({super.key, required this.createRequests});

  final Stream<void> createRequests;

  Future<void> _openForm(BuildContext context, {Cliente? cliente}) async {
    final cubit = context.read<AdminClientesCubit>();
    final form = ClienteFormController(cubit.draftFor(cliente));
    await showAdminFormModal<Cliente>(
      context: context,
      cubit: cubit,
      title: cliente == null ? 'Nuevo Cliente' : 'Editar Cliente',
      submitLabel: 'Guardar Cliente',
      body: ClienteFormBody(form: form),
      onSubmit: () => cubit.saveCliente(form.toDraft(), uuid: cliente?.uuid),
    );
  }

  Future<void> _delete(BuildContext context, Cliente cliente) async {
    final cubit = context.read<AdminClientesCubit>();
    final confirmed = await confirmAdminDelete(
      context,
      '¿Eliminar al cliente "${cliente.razonSocial}"?',
    );
    if (confirmed && !cubit.isClosed) await cubit.deleteCliente(cliente);
  }

  @override
  Widget build(BuildContext context) {
    return AdminCrudHost<AdminClientesCubit, Cliente>(
      createRequests: createRequests,
      onCreate: (context) => _openForm(context),
      builder: (context, state) => AdminTableCard<Cliente>(
        title: 'Directorio de Clientes Registrados',
        countLabel: '${state.items.length} clientes',
        emptyMessage: 'No hay clientes registrados',
        loading: state.loading,
        rows: state.items,
        columns: [
          ResponsiveColumn(
            label: 'Razón Social / Nombre',
            cellBuilder: (_, cliente) => Text(
              cliente.razonSocial,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Tipo & Identificación',
            cellBuilder: (_, cliente) => _IdentificacionCell(cliente: cliente),
          ),
          ResponsiveColumn(
            label: 'Email',
            cellBuilder: (_, cliente) => _OptionalText(cliente.email),
          ),
          ResponsiveColumn(
            label: 'Teléfono',
            cellBuilder: (_, cliente) => _OptionalText(cliente.telefono),
          ),
          ResponsiveColumn(
            label: 'Acciones',
            alignEnd: true,
            cellBuilder: (context, cliente) => AdminRowActions(
              onEdit: () => _openForm(context, cliente: cliente),
              onDelete: () => _delete(context, cliente),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentificacionCell extends StatelessWidget {
  const _IdentificacionCell({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cliente.tipoIdentificacion.toJson(),
          style: AppTextStyles.text10.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.gray400,
          ),
        ),
        Text(
          cliente.identificacion,
          style: AppTextStyles.mono.copyWith(color: AppColors.gray700),
        ),
      ],
    );
  }
}

class _OptionalText extends StatelessWidget {
  const _OptionalText(this.value);

  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value;
    return Text(
      text == null || text.isEmpty ? '-' : text,
      style: AppTextStyles.xs.copyWith(color: AppColors.gray600),
    );
  }
}

class ClienteFormController extends ChangeNotifier {
  ClienteFormController(ClienteDraft draft)
    : razonSocial = TextEditingController(text: draft.razonSocial),
      identificacion = TextEditingController(text: draft.identificacion),
      email = TextEditingController(text: draft.email ?? ''),
      telefono = TextEditingController(text: draft.telefono ?? ''),
      direccion = TextEditingController(text: draft.direccion ?? ''),
      _tipoIdentificacion = draft.tipoIdentificacion;

  final TextEditingController razonSocial;
  final TextEditingController identificacion;
  final TextEditingController email;
  final TextEditingController telefono;
  final TextEditingController direccion;
  TipoIdentificacion _tipoIdentificacion;

  TipoIdentificacion get tipoIdentificacion => _tipoIdentificacion;

  set tipoIdentificacion(TipoIdentificacion value) {
    _tipoIdentificacion = value;
    notifyListeners();
  }

  ClienteDraft toDraft() => ClienteDraft(
    tipoIdentificacion: _tipoIdentificacion,
    identificacion: identificacion.text,
    razonSocial: razonSocial.text,
    direccion: direccion.text,
    telefono: telefono.text,
    email: email.text,
  );

  @override
  void dispose() {
    razonSocial.dispose();
    identificacion.dispose();
    email.dispose();
    telefono.dispose();
    direccion.dispose();
    super.dispose();
  }
}

class ClienteFormBody extends StatefulWidget {
  const ClienteFormBody({super.key, required this.form});

  final ClienteFormController form;

  @override
  State<ClienteFormBody> createState() => _ClienteFormBodyState();
}

class _ClienteFormBodyState extends State<ClienteFormBody> {
  ClienteFormController get form => widget.form;

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
            key: const ValueKey('cliente.razonSocial'),
            label: 'Razón Social o Nombre',
            required: true,
            controller: form.razonSocial,
          ),
          AppSpacing.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppDropdownField<TipoIdentificacion>(
                  key: const ValueKey('cliente.tipo'),
                  label: 'Tipo de Identificación',
                  required: true,
                  value: form.tipoIdentificacion,
                  onChanged: (value) {
                    if (value != null) form.tipoIdentificacion = value;
                  },
                  items: [
                    for (final entry in _tipoLabels.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: AppTextField(
                  key: const ValueKey('cliente.identificacion'),
                  label: 'Identificación',
                  required: true,
                  controller: form.identificacion,
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
                  key: const ValueKey('cliente.email'),
                  label: 'Email',
                  controller: form.email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: AppTextField(
                  key: const ValueKey('cliente.telefono'),
                  label: 'Teléfono',
                  controller: form.telefono,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          AppSpacing.h16,
          AppTextField(
            key: const ValueKey('cliente.direccion'),
            label: 'Dirección',
            controller: form.direccion,
          ),
        ],
      ),
    );
  }
}
