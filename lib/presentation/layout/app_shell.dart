import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/app_navbar.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.navActions = const [],
    this.drawer,
  });

  final Widget child;

  final List<Widget> navActions;

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppNavbar(actions: navActions),
      drawer: drawer,
      body: child,
    );
  }
}
