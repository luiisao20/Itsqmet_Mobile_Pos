import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/router/app_routes.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/tipo_identificacion.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/widgets/auth_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/register_cubit.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/register_state.dart';
import 'package:material_ui/material_ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const Key identificacionKey = ValueKey('register-identificacion');
  static const Key razonSocialKey = ValueKey('register-razon-social');
  static const Key emailKey = ValueKey('register-email');
  static const Key telefonoKey = ValueKey('register-telefono');
  static const Key direccionKey = ValueKey('register-direccion');
  static const Key passwordKey = ValueKey('register-password');

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterCubit _cubit = RegisterCubit();
  final TextEditingController _identificacion = TextEditingController();
  final TextEditingController _razonSocial = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _direccion = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _cubit.close();
    for (final controller in [
      _identificacion,
      _razonSocial,
      _email,
      _telefono,
      _direccion,
      _password,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() => _cubit.submit(
    identificacion: _identificacion.text,
    razonSocial: _razonSocial.text,
    direccion: _direccion.text,
    telefono: _telefono.text,
    email: _email.text,
    password: _password.text,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      bloc: _cubit,
      builder: (context, state) => AuthCard(
        maxWidth: 512,
        icon: Icons.edit_note,
        title: 'Registro de Cliente',
        subtitle: 'Crea tu cuenta para realizar pedidos para llevar y gestionar tus facturas',
        children: [
          if (state.errorMessage != null) ...[
            ErrorBanner(message: state.errorMessage!),
            AppSpacing.h16,
          ],
          _pair(
            AppDropdownField<TipoIdentificacion>(
              label: 'Tipo de Identificación',
              required: true,
              value: state.tipoIdentificacion,
              items: [
                for (final tipo in TipoIdentificacion.values)
                  DropdownMenuItem(value: tipo, child: Text(tipo.label)),
              ],
              onChanged: (tipo) {
                if (tipo != null) _cubit.setTipoIdentificacion(tipo);
              },
            ),
            AppTextField(
              key: RegisterScreen.identificacionKey,
              controller: _identificacion,
              label: 'Número de Documento',
              required: true,
              hint: 'ej: 1718293041',
              textInputAction: TextInputAction.next,
            ),
          ),
          AppSpacing.h16,
          AppTextField(
            key: RegisterScreen.razonSocialKey,
            controller: _razonSocial,
            label: 'Nombres Completos o Razón Social',
            required: true,
            hint: 'ej: Juan Fernando Pérez',
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.h16,
          _pair(
            AppTextField(
              key: RegisterScreen.emailKey,
              controller: _email,
              label: 'Correo Electrónico',
              required: true,
              hint: 'juan.perez@gmail.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            AppTextField(
              key: RegisterScreen.telefonoKey,
              controller: _telefono,
              label: 'Teléfono Móvil',
              hint: '0998765432',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
          ),
          AppSpacing.h16,
          AppTextField(
            key: RegisterScreen.direccionKey,
            controller: _direccion,
            label: 'Dirección Domiciliaria',
            hint: 'Av. Amazonas y República',
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.h16,
          AppTextField(
            key: RegisterScreen.passwordKey,
            controller: _password,
            label: 'Contraseña (mínimo 6 caracteres)',
            required: true,
            hint: '••••••••',
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          AppSpacing.h24,
          AppButton(
            label: 'Registrar y Continuar',
            loadingLabel: 'Creando cuenta...',
            loading: state.loading,
            size: AppButtonSize.lg,
            expand: true,
            onPressed: _submit,
          ),
          AppSpacing.h16,
          AuthFooterLink(
            question: '¿Ya tienes cuenta?',
            action: 'Inicia sesión aquí',
            onTap: () => context.go(AppRoutes.login.path),
          ),
        ],
      ),
    );
  }

  Widget _pair(Widget first, Widget second) {
    if (!context.atLeastSm) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, AppSpacing.h16, second],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        AppSpacing.w16,
        Expanded(child: second),
      ],
    );
  }
}
