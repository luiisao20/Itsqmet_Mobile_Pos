import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/domain.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_crud_host.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_form_modal.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_row_actions.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/admin/widgets/admin_table_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/role_chip.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/status_badges.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/composite/responsive_data_table.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_checkbox_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_dropdown_field.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/admin_personas/admin_usuarios_cubit.dart';
import 'package:itsqmet_mobile_pos/services/locator/service_locator.dart';
import 'package:material_ui/material_ui.dart';

class PersonalTab extends StatelessWidget {
  const PersonalTab({super.key, required this.createRequests});

  final Stream<void> createRequests;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminUsuariosCubit>(
      create: (_) => getIt<AdminUsuariosCubit>()..load(),
      child: PersonalView(createRequests: createRequests),
    );
  }
}

class PersonalView extends StatelessWidget {
  const PersonalView({super.key, required this.createRequests});

  final Stream<void> createRequests;

  Future<void> _openForm(BuildContext context, {Usuario? usuario}) async {
    final cubit = context.read<AdminUsuariosCubit>();
    final form = UsuarioFormController(cubit.draftFor(usuario));
    await showAdminFormModal<Usuario>(
      context: context,
      cubit: cubit,
      title: usuario == null ? 'Nuevo Empleado' : 'Editar Empleado',
      submitLabel: 'Guardar Empleado',
      body: UsuarioFormBody(form: form, editing: usuario != null),
      onSubmit: () => cubit.saveUsuario(form.toDraft(), uuid: usuario?.uuid),
    );
  }

  Future<void> _delete(BuildContext context, Usuario usuario) async {
    final cubit = context.read<AdminUsuariosCubit>();
    final confirmed = await confirmAdminDelete(
      context,
      '¿Eliminar al empleado ${usuario.nombre} ${usuario.apellido}?',
    );
    if (confirmed && !cubit.isClosed) await cubit.deleteUsuario(usuario);
  }

  @override
  Widget build(BuildContext context) {
    return AdminCrudHost<AdminUsuariosCubit, Usuario>(
      createRequests: createRequests,
      onCreate: (context) => _openForm(context),
      builder: (context, state) => AdminTableCard<Usuario>(
        title: 'Personal del Restaurante',
        countLabel: '${state.items.length} empleados',
        emptyMessage: 'No hay empleados registrados',
        loading: state.loading,
        rows: state.items,
        columns: [
          ResponsiveColumn(
            label: 'Nombre',
            cellBuilder: (_, usuario) => Text(
              '${usuario.nombre} ${usuario.apellido}',
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Cédula',
            cellBuilder: (_, usuario) => Text(
              usuario.cedula,
              style: AppTextStyles.mono.copyWith(color: AppColors.gray500),
            ),
          ),
          ResponsiveColumn(
            label: 'Email',
            cellBuilder: (_, usuario) => Text(
              usuario.email,
              style: AppTextStyles.xs.copyWith(color: AppColors.gray600),
            ),
          ),
          ResponsiveColumn(
            label: 'Rol',
            cellBuilder: (_, usuario) => RoleChip(usuario.rol.toJson()),
          ),
          ResponsiveColumn(
            label: 'Estado',
            cellBuilder: (context, usuario) => Tooltip(
              message: 'Cambiar activo',
              child: InkWell(
                onTap: () =>
                    context.read<AdminUsuariosCubit>().toggleActivo(usuario),
                borderRadius: AppRadius.fullAll,
                child: StatusBadge(StatusBadges.activo(usuario.activo)),
              ),
            ),
          ),
          ResponsiveColumn(
            label: 'Acciones',
            alignEnd: true,
            cellBuilder: (context, usuario) => AdminRowActions(
              onEdit: () => _openForm(context, usuario: usuario),
              onDelete: () => _delete(context, usuario),
            ),
          ),
        ],
      ),
    );
  }
}

class UsuarioFormController extends ChangeNotifier {
  UsuarioFormController(UsuarioDraft draft)
    : nombre = TextEditingController(text: draft.nombre),
      apellido = TextEditingController(text: draft.apellido),
      cedula = TextEditingController(text: draft.cedula),
      email = TextEditingController(text: draft.email),
      password = TextEditingController(text: draft.password ?? ''),
      _rol = draft.rol,
      _activo = draft.activo;

  final TextEditingController nombre;
  final TextEditingController apellido;
  final TextEditingController cedula;
  final TextEditingController email;
  final TextEditingController password;
  Rol _rol;
  bool _activo;

  Rol get rol => _rol;
  bool get activo => _activo;

  set rol(Rol value) {
    _rol = value;
    notifyListeners();
  }

  set activo(bool value) {
    _activo = value;
    notifyListeners();
  }

  UsuarioDraft toDraft() => UsuarioDraft(
    nombre: nombre.text,
    apellido: apellido.text,
    cedula: cedula.text,
    email: email.text,
    password: password.text,
    rol: _rol,
    activo: _activo,
  );

  @override
  void dispose() {
    nombre.dispose();
    apellido.dispose();
    cedula.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }
}

class UsuarioFormBody extends StatefulWidget {
  const UsuarioFormBody({super.key, required this.form, required this.editing});

  static const List<Rol> roles = [
    Rol.mesero,
    Rol.cocina,
    Rol.admin,
    Rol.cliente,
  ];

  final UsuarioFormController form;
  final bool editing;

  @override
  State<UsuarioFormBody> createState() => _UsuarioFormBodyState();
}

class _UsuarioFormBodyState extends State<UsuarioFormBody> {
  UsuarioFormController get form => widget.form;

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
                  key: const ValueKey('usuario.nombre'),
                  label: 'Nombre',
                  required: true,
                  controller: form.nombre,
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: AppTextField(
                  key: const ValueKey('usuario.apellido'),
                  label: 'Apellido',
                  required: true,
                  controller: form.apellido,
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
                  key: const ValueKey('usuario.cedula'),
                  label: 'Cédula',
                  required: true,
                  controller: form.cedula,
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: AppDropdownField<Rol>(
                  label: 'Rol Operativo',
                  required: true,
                  value: form.rol,
                  onChanged: (value) {
                    if (value != null) form.rol = value;
                  },
                  items: [
                    for (final rol in UsuarioFormBody.roles)
                      DropdownMenuItem(
                        value: rol,
                        child: Text(
                          rol.toJson(),
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.xs.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.h16,
          AppTextField(
            key: const ValueKey('usuario.email'),
            label: 'Email',
            required: true,
            controller: form.email,
            keyboardType: TextInputType.emailAddress,
          ),
          AppSpacing.h16,
          AppTextField(
            key: const ValueKey('usuario.password'),
            label: widget.editing
                ? 'Contraseña (Dejar en blanco para no modificar)'
                : 'Contraseña',
            required: !widget.editing,
            hint: 'Mínimo 4 caracteres',
            controller: form.password,
            obscureText: true,
          ),
          AppSpacing.h16,
          AppCheckboxField(
            label: 'Usuario Activo',
            value: form.activo,
            onChanged: (value) => form.activo = value,
          ),
        ],
      ),
    );
  }
}
