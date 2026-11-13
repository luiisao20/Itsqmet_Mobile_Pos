import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/router/app_routes.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/screens/auth/widgets/auth_card.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/widgets.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/login_cubit.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/login_state.dart';
import 'package:material_ui/material_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const Key clienteLoginKey = ValueKey('login-cliente-login');
  static const Key clientePasswordKey = ValueKey('login-cliente-password');
  static const Key staffEmailKey = ValueKey('login-staff-email');
  static const Key staffPasswordKey = ValueKey('login-staff-password');

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginCubit _cubit = LoginCubit();
  final TextEditingController _clienteLogin = TextEditingController();
  final TextEditingController _clientePassword = TextEditingController();
  final TextEditingController _staffEmail = TextEditingController();
  final TextEditingController _staffPassword = TextEditingController();

  @override
  void dispose() {
    _cubit.close();
    _clienteLogin.dispose();
    _clientePassword.dispose();
    _staffEmail.dispose();
    _staffPassword.dispose();
    super.dispose();
  }

  void _submitCliente() => _cubit.submitCliente(
    login: _clienteLogin.text,
    password: _clientePassword.text,
  );

  void _submitStaff() => _cubit.submitStaff(
    email: _staffEmail.text,
    password: _staffPassword.text,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      bloc: _cubit,
      builder: (context, state) {
        final isCliente = state.tab == LoginTab.cliente;
        return AuthCard(
          maxWidth: 448,
          icon: Icons.lock_outline,
          title: 'Iniciar Sesión',
          subtitle:
              'Ingresa con tu cuenta de cliente o credenciales de personal',
          children: [
            _LoginTabs(selected: state.tab, onChanged: _cubit.setTab),
            AppSpacing.h24,
            if (state.errorMessage != null) ...[
              ErrorBanner(message: state.errorMessage!),
              AppSpacing.h16,
            ],
            if (isCliente) ..._clienteForm(state) else ..._staffForm(state),
          ],
        );
      },
    );
  }

  List<Widget> _clienteForm(LoginState state) => [
    AppTextField(
      key: LoginScreen.clienteLoginKey,
      controller: _clienteLogin,
      label: 'Correo Electrónico o Cédula / RUC',
      hint: 'ej: juan.perez@gmail.com o 1718293041',
      textInputAction: TextInputAction.next,
    ),
    AppSpacing.h16,
    AppTextField(
      key: LoginScreen.clientePasswordKey,
      controller: _clientePassword,
      label: 'Contraseña',
      hint: '••••••••',
      obscureText: true,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submitCliente(),
    ),
    AppSpacing.h24,
    AppButton(
      label: 'Iniciar Sesión como Cliente',
      loadingLabel: 'Ingresando...',
      loading: state.loading,
      size: AppButtonSize.lg,
      expand: true,
      onPressed: _submitCliente,
    ),
    AppSpacing.h16,
    AuthFooterLink(
      question: '¿No tienes cuenta?',
      action: 'Regístrate aquí',
      onTap: () => context.go(AppRoutes.register.path),
    ),
  ];

  List<Widget> _staffForm(LoginState state) => [
    AppTextField(
      key: LoginScreen.staffEmailKey,
      controller: _staffEmail,
      label: 'Correo Corporativo',
      hint: 'admin@restaurant.com',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    ),
    AppSpacing.h16,
    AppTextField(
      key: LoginScreen.staffPasswordKey,
      controller: _staffPassword,
      label: 'Contraseña de Acceso',
      hint: '••••••••',
      obscureText: true,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submitStaff(),
    ),
    AppSpacing.h24,
    AppButton(
      label: 'Acceder al Sistema POS',
      loadingLabel: 'Verificando...',
      loading: state.loading,
      size: AppButtonSize.lg,
      expand: true,
      onPressed: _submitStaff,
    ),
  ];
}

class _LoginTabs extends StatelessWidget {
  const _LoginTabs({required this.selected, required this.onChanged});

  final LoginTab selected;
  final ValueChanged<LoginTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s1),
      decoration: BoxDecoration(
        color: AppColors.emerald50.withValues(alpha: 0.7),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.emerald200.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _tab(LoginTab.cliente, 'Soy Cliente'),
          AppSpacing.w4,
          _tab(LoginTab.staff, 'Personal / Staff'),
        ],
      ),
    );
  }

  Widget _tab(LoginTab tab, String label) {
    final active = tab == selected;
    return Expanded(
      child: Material(
        color: active ? AppColors.white : Colors.transparent,
        borderRadius: AppRadius.smAll,
        shadowColor: Colors.black26,
        elevation: active ? 1 : 0,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: () => onChanged(tab),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: active ? AppColors.emerald900 : AppColors.emerald700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
