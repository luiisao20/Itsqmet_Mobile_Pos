import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/app_logo.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({super.key, this.actions = const []});

  final List<Widget> actions;

  static const double height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    final showMenuButton = context.isMobile && (scaffold?.hasDrawer ?? false);

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
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppLogo(),
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
