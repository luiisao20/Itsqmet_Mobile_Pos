import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/router/app_route.dart';
import 'package:itsqmet_mobile_pos/config/router/app_routes.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/auth_user.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/rol.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/app_logo.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/badges/app_badge.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_cubit.dart';
import 'package:itsqmet_mobile_pos/providers/cubits/auth/auth_state.dart';
import 'package:material_ui/material_ui.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({super.key, this.actions = const [], this.authCubit});

  final List<Widget> actions;

  final AuthCubit? authCubit;

  static const double height = 64;

  static const Key userMenuKey = ValueKey('navbar-user-menu');
  static const Key mobileMenuKey = ValueKey('navbar-mobile-menu');

  static const double _sessionAreaMaxFraction = 0.45;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  AuthCubit? _resolveAuth() {
    if (authCubit != null) return authCubit;
    final getIt = GetIt.instance;
    return getIt.isRegistered<AuthCubit>() ? getIt<AuthCubit>() : null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = _resolveAuth();
    if (auth == null) return _NavbarFrame(children: _withActions(const []));

    return BlocBuilder<AuthCubit, AuthState>(
      bloc: auth,
      builder: (context, state) {
        final path = _currentPath(context);
        final wide = context.atLeastMd;
        return _NavbarFrame(
          showDrawerButton: false,
          expandLogo: false,
          children: _withActions([
            if (wide)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: AppSpacing.s6),
                  child: Row(
                    children: [
                      for (final link in _NavLink.forRol(state.rol))
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.s1),
                          child: _DesktopLink(
                            link: link,
                            active: link.isActive(path),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (wide)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.screenWidth * _sessionAreaMaxFraction,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _SessionArea(auth: auth, state: state),
                ),
              )
            else ...[
              const Spacer(),
              IconButton(
                tooltip: 'Menú',
                onPressed: () => _showMobileMenu(context, auth),
                icon: const Icon(Icons.menu, color: AppColors.gray600),
              ),
            ],
          ]),
        );
      },
    );
  }

  List<Widget> _withActions(List<Widget> children) => [...children, ...actions];

  static String? _currentPath(BuildContext context) =>
      GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration.uri.path;
}

class _NavbarFrame extends StatelessWidget {
  const _NavbarFrame({
    required this.children,
    this.showDrawerButton = true,
    this.expandLogo = true,
  });

  final List<Widget> children;
  final bool showDrawerButton;
  final bool expandLogo;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    final showMenuButton =
        showDrawerButton && context.isMobile && (scaffold?.hasDrawer ?? false);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        border: const Border(bottom: BorderSide(color: AppColors.emerald100)),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Breakpoints.xl),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
              child: Row(
                children: [
                  if (showMenuButton)
                    IconButton(
                      tooltip: 'Menú',
                      onPressed: scaffold!.openDrawer,
                      icon: const Icon(Icons.menu, color: AppColors.gray700),
                    ),
                  if (!expandLogo)
                    const AppLogo()
                  else
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppLogo(),
                      ),
                    ),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink {
  const _NavLink(this.label, this.route, {this.icon, this.pulse = false});

  final String label;
  final AppRoute route;
  final IconData? icon;
  final bool pulse;

  bool isActive(String? path) {
    if (path == null) return false;
    if (route == AppRoutes.home) return path == route.path;
    return path == route.path || path.startsWith('${route.path}/');
  }

  static List<_NavLink> forRol(Rol? rol) => [
    const _NavLink('Menú Digital', AppRoutes.home),
    if (rol == Rol.cliente)
      const _NavLink(
        'Para Llevar / Mis Pedidos',
        AppRoutes.clientePedidos,
        icon: Icons.shopping_bag_outlined,
      ),
    if (rol == Rol.admin || rol == Rol.mesero) ...const [
      _NavLink(
        'Mesas & Salón',
        AppRoutes.mesas,
        icon: Icons.table_restaurant_outlined,
      ),
      _NavLink('Caja & Facturación', AppRoutes.caja, icon: Icons.credit_card),
    ],
    if (rol == Rol.admin || rol == Rol.cocina || rol == Rol.mesero)
      const _NavLink(
        'Monitor Cocina',
        AppRoutes.cocina,
        icon: Icons.soup_kitchen_outlined,
        pulse: true,
      ),
    if (rol == Rol.admin)
      const _NavLink(
        'Administración',
        AppRoutes.admin,
        icon: Icons.settings_outlined,
      ),
  ];
}

class _DesktopLink extends StatelessWidget {
  const _DesktopLink({required this.link, required this.active});

  final _NavLink link;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.emerald800 : AppColors.gray600;
    return Material(
      color: active ? AppColors.emerald50 : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.smAll,
        side: BorderSide(
          color: active ? AppColors.emerald200 : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.smAll,
        hoverColor: AppColors.emerald50.withValues(alpha: 0.5),
        onTap: () => context.go(link.route.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (link.pulse) ...[const _PulseDot(), const SizedBox(width: 6)],
              if (link.icon != null) ...[
                Icon(link.icon, size: 14, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                link.label,
                style: AppTextStyles.xs.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.emerald500,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SessionArea extends StatelessWidget {
  const _SessionArea({required this.auth, required this.state});

  final AuthCubit auth;
  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final user = state.user;
    if (state.isUnknown) return const SizedBox.shrink();
    if (user == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => context.go(AppRoutes.login.path),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.emerald700,
              textStyle: AppTextStyles.xs.copyWith(fontWeight: FontWeight.w500),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.smAll,
              ),
            ),
            child: const Text('Iniciar Sesión'),
          ),
          AppSpacing.w12,
          FilledButton(
            onPressed: () => context.go(AppRoutes.register.path),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.emerald600,
              foregroundColor: AppColors.white,
              textStyle: AppTextStyles.xs.copyWith(fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: const Size(0, 32),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.smAll,
              ),
            ),
            child: const Text('Crear Cuenta Cliente'),
          ),
        ],
      );
    }
    return _UserMenu(auth: auth, user: user);
  }
}

enum _UserMenuAction { clientePedidos, admin, logout }

class _UserMenu extends StatelessWidget {
  const _UserMenu({required this.auth, required this.user});

  final AuthCubit auth;
  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final rol = user.rol;
    return PopupMenuButton<_UserMenuAction>(
      key: AppNavbar.userMenuKey,
      tooltip: '',
      position: PopupMenuPosition.under,
      offset: const Offset(0, AppSpacing.s2),
      constraints: const BoxConstraints.tightFor(width: 224),
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: AppColors.emerald100),
      ),
      onSelected: (action) => _onSelected(context, action),
      itemBuilder: (context) => [
        PopupMenuItem<_UserMenuAction>(
          enabled: false,
          child: _UserSummary(user: user),
        ),
        const PopupMenuDivider(height: 1),
        if (rol == Rol.cliente)
          _item(
            _UserMenuAction.clientePedidos,
            Icons.shopping_bag_outlined,
            'Mis Pedidos y Facturas',
          ),
        if (rol == Rol.admin)
          _item(
            _UserMenuAction.admin,
            Icons.settings_outlined,
            'Gestión del Sistema',
          ),
        if (rol == Rol.cliente || rol == Rol.admin)
          const PopupMenuDivider(height: 1),
        PopupMenuItem<_UserMenuAction>(
          value: _UserMenuAction.logout,
          height: 36,
          child: Text(
            'Cerrar Sesión',
            style: AppTextStyles.xs.copyWith(color: AppColors.rose600),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Avatar(user: user),
            if (context.atLeastLg) ...[
              AppSpacing.w8,
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nombre,
                    style: AppTextStyles.xs.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray800,
                      height: 1.25,
                    ),
                  ),
                  Text(
                    rol.toJson(),
                    style: AppTextStyles.text10.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.emerald600,
                    ),
                  ),
                ],
              ),
            ],
            AppSpacing.w8,
            const Icon(Icons.expand_more, size: 16, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<_UserMenuAction> _item(
    _UserMenuAction action,
    IconData icon,
    String label,
  ) => PopupMenuItem<_UserMenuAction>(
    value: action,
    height: 36,
    child: Row(
      children: [
        Icon(icon, size: 14, color: AppColors.gray700),
        AppSpacing.w8,
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.xs.copyWith(color: AppColors.gray700),
          ),
        ),
      ],
    ),
  );

  Future<void> _onSelected(BuildContext context, _UserMenuAction action) async {
    switch (action) {
      case _UserMenuAction.clientePedidos:
        context.go(AppRoutes.clientePedidos.path);
      case _UserMenuAction.admin:
        context.go(AppRoutes.admin.path);
      case _UserMenuAction.logout:
        await _logoutAndGoToLogin(context, auth);
    }
  }
}

class _UserSummary extends StatelessWidget {
  const _UserSummary({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${user.nombre} ${user.apellido}'.trim(),
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.xs.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        Text(
          user.email,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.text11.copyWith(color: AppColors.gray400),
        ),
        AppSpacing.h4,
        AppBadge(label: user.rol.toJson(), variant: BadgeVariant.success),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final nombre = user.nombre;
    final initial = nombre.isEmpty
        ? 'U'
        : String.fromCharCode(nombre.runes.first);
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.emerald100,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        initial,
        style: AppTextStyles.xs.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.emerald800,
        ),
      ),
    );
  }
}

Future<void> _logoutAndGoToLogin(BuildContext context, AuthCubit auth) async {
  final router = GoRouter.maybeOf(context);
  await auth.logout();
  router?.go(AppRoutes.login.path);
}

Future<void> _showMobileMenu(BuildContext context, AuthCubit auth) {
  final router = GoRouter.maybeOf(context);
  final top = MediaQuery.paddingOf(context).top + AppNavbar.height;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar menú',
    barrierColor: Colors.black12,
    pageBuilder: (dialogContext, _, _) {
      void close() => Navigator.of(dialogContext).pop();
      void go(String path) {
        close();
        router?.go(path);
      }

      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: top),
          child: Material(
            color: AppColors.white,
            child: _MobileMenu(
              key: AppNavbar.mobileMenuKey,
              auth: auth,
              onNavigate: go,
              onLogout: () async {
                close();
                await auth.logout();
                router?.go(AppRoutes.login.path);
              },
            ),
          ),
        ),
      );
    },
  );
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({
    super.key,
    required this.auth,
    required this.onNavigate,
    required this.onLogout,
  });

  final AuthCubit auth;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: auth,
      builder: (context, state) {
        final user = state.user;
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.gray100)),
            boxShadow: AppShadows.md,
            color: AppColors.white,
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s4,
            AppSpacing.s2,
            AppSpacing.s4,
            AppSpacing.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final link in _NavLink.forRol(state.rol))
                _MobileEntry(
                  label: link.label,
                  icon: link.icon,
                  onTap: () => onNavigate(link.route.path),
                ),
              AppSpacing.h4,
              Container(
                padding: const EdgeInsets.only(top: AppSpacing.s3),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.gray100)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: user == null
                      ? [
                          _MobileEntry(
                            label: 'Iniciar Sesión',
                            color: AppColors.emerald700,
                            bold: true,
                            onTap: () => onNavigate(AppRoutes.login.path),
                          ),
                          _MobileEntry(
                            label: 'Registrarse',
                            color: AppColors.emerald600,
                            bold: true,
                            onTap: () => onNavigate(AppRoutes.register.path),
                          ),
                        ]
                      : [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s3,
                              vertical: AppSpacing.s2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.nombre,
                                  style: AppTextStyles.xs.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gray900,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: AppTextStyles.text11.copyWith(
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _MobileEntry(
                            label: 'Cerrar Sesión',
                            color: AppColors.rose600,
                            bold: true,
                            onTap: onLogout,
                          ),
                        ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MobileEntry extends StatelessWidget {
  const _MobileEntry({
    required this.label,
    required this.onTap,
    this.icon,
    this.color = AppColors.gray700,
    this.bold = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      hoverColor: AppColors.emerald50,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s2,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              AppSpacing.w8,
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sm.copyWith(
                  color: color,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
