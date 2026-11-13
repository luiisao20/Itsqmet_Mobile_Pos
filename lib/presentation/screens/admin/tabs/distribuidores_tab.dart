import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_crud_host.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_form_modal.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_row_actions.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_table_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/responsive_data_table.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/distribuidores_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

class DistribuidoresTab extends StatelessWidget {
  const DistribuidoresTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DistribuidoresCubit>(
      create: (_) => getIt<DistribuidoresCubit>()..load(),
      child: DistribuidoresView(createRequests: createRequests),
    );
  }
}

class DistribuidoresView extends StatelessWidget {
  const DistribuidoresView({super.key, required this.createRequests});

  final Stream<void> createRequests;

  Future<void> _openForm(
    BuildContext context, {
    Distribuidor? distribuidor,
  }) async {
    final cubit = context.read<DistribuidoresCubit>();
    final form = DistribuidorFormController(cubit.draftFor(distribuidor));
    await showAdminFormModal<Distribuidor>(
      context: context,
      cubit: cubit,
      title: distribuidor == null
          ? 'Nuevo Distribuidor'
          : 'Editar Distribuidor',
      submitLabel: 'Guardar Distribuidor',
      body: DistribuidorFormBody(form: form),
      onSubmit: () =>
          cubit.saveDistribuidor(form.toDraft(), id: distribuidor?.id),
    );
  }

  Future<void> _delete(BuildContext context, Distribuidor distribuidor) async {
    final cubit = context.read<DistribuidoresCubit>();
    final confirmed = await confirmAdminDelete(
      context,
      '¿Eliminar al proveedor "${distribuidor.razonSocial}"?',
    );
    if (confirmed && !cubit.isClosed) {
      await cubit.deleteDistribuidor(distribuidor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminCrudHost<DistribuidoresCubit, Distribuidor>(
      createRequests: createRequests,
      onCreate: (context) => _openForm(context),
      builder: (context, state) => AdminTableCard<Distribuidor>(
        title: 'Directorio de Distribuidores y Proveedores',
        countLabel: '${state.items.length} proveedores',
        emptyMessage: 'No hay distribuidores registrados',
        loading: state.loading,
        rows: state.items,
        columns: [
          ResponsiveColumn(
            label: 'Razón Social',
            cellBuilder: (_, distribuidor) => Text(
              distribuidor.razonSocial,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'RUC',
            cellBuilder: (_, distribuidor) => Text(
              distribuidor.ruc,
              style: AppTextStyles.mono.copyWith(color: AppColors.gray500),
            ),
          ),
          ResponsiveColumn(
            label: 'Contacto',
            cellBuilder: (_, distribuidor) => Text(
              _orDash(distribuidor.nombreContacto),
              style: AppTextStyles.xs.copyWith(color: AppColors.gray700),
            ),
          ),
          ResponsiveColumn(
            label: 'Teléfono / Email',
            cellBuilder: (_, distribuidor) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _orDash(distribuidor.telefono),
                  style: AppTextStyles.xs.copyWith(color: AppColors.gray800),
                ),
                Text(
                  _orDash(distribuidor.email),
                  style: AppTextStyles.text11.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          ResponsiveColumn(
            label: 'Categoría',
            cellBuilder: (_, distribuidor) => _CategoriaChip(
              label: _orFallback(distribuidor.categoriaProveedor, 'General'),
            ),
          ),
          ResponsiveColumn(
            label: 'Acciones',
            alignEnd: true,
            cellBuilder: (context, distribuidor) => AdminRowActions(
              onEdit: () => _openForm(context, distribuidor: distribuidor),
              onDelete: () => _delete(context, distribuidor),
            ),
          ),
        ],
      ),
    );
  }

  static String _orDash(String? value) => _orFallback(value, '-');

  static String _orFallback(String? value, String fallback) =>
      value == null || value.isEmpty ? fallback : value;
}

class _CategoriaChip extends StatelessWidget {
  const _CategoriaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: AppTextStyles.text11.copyWith(color: AppColors.gray700),
      ),
    );
  }
}

class DistribuidorFormController {
  DistribuidorFormController(DistribuidorDraft draft)
    : ruc = TextEditingController(text: draft.ruc),
      razonSocial = TextEditingController(text: draft.razonSocial),
      nombreContacto = TextEditingController(text: draft.nombreContacto ?? ''),
      telefono = TextEditingController(text: draft.telefono ?? ''),
      email = TextEditingController(text: draft.email ?? ''),
      direccion = TextEditingController(text: draft.direccion ?? ''),
      categoriaProveedor = TextEditingController(
        text: draft.categoriaProveedor ?? '',
      );

  final TextEditingController ruc;
  final TextEditingController razonSocial;
  final TextEditingController nombreContacto;
  final TextEditingController telefono;
  final TextEditingController email;
  final TextEditingController direccion;
  final TextEditingController categoriaProveedor;

  DistribuidorDraft toDraft() => DistribuidorDraft(
    ruc: ruc.text,
    razonSocial: razonSocial.text,
    nombreContacto: nombreContacto.text,
    telefono: telefono.text,
    email: email.text,
    direccion: direccion.text,
    categoriaProveedor: categoriaProveedor.text,
  );

  void dispose() {
    ruc.dispose();
    razonSocial.dispose();
    nombreContacto.dispose();
    telefono.dispose();
    email.dispose();
    direccion.dispose();
    categoriaProveedor.dispose();
  }
}

class DistribuidorFormBody extends StatefulWidget {
  const DistribuidorFormBody({super.key, required this.form});

  final DistribuidorFormController form;

  @override
  State<DistribuidorFormBody> createState() => _DistribuidorFormBodyState();
}

class _DistribuidorFormBodyState extends State<DistribuidorFormBody> {
  DistribuidorFormController get form => widget.form;

  @override
  void dispose() {
    widget.form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          key: const ValueKey('distribuidor.razonSocial'),
          label: 'Razón Social',
          required: true,
          hint: 'Ej: Pronaca Cía. Ltda.',
          controller: form.razonSocial,
        ),
        AppSpacing.h16,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                key: const ValueKey('distribuidor.ruc'),
                label: 'RUC',
                required: true,
                controller: form.ruc,
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: AppTextField(
                key: const ValueKey('distribuidor.categoria'),
                label: 'Categoría',
                hint: 'Ej: Carnes, Lácteos, Abarrotes',
                controller: form.categoriaProveedor,
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
                key: const ValueKey('distribuidor.contacto'),
                label: 'Contacto',
                controller: form.nombreContacto,
                keyboardType: TextInputType.name,
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: AppTextField(
                key: const ValueKey('distribuidor.telefono'),
                label: 'Teléfono',
                controller: form.telefono,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        AppSpacing.h16,
        AppTextField(
          key: const ValueKey('distribuidor.email'),
          label: 'Email',
          controller: form.email,
          keyboardType: TextInputType.emailAddress,
        ),
        AppSpacing.h16,
        AppTextField(
          key: const ValueKey('distribuidor.direccion'),
          label: 'Dirección',
          controller: form.direccion,
          keyboardType: TextInputType.streetAddress,
        ),
      ],
    );
  }
}
