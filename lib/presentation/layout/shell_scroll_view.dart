import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/app_footer.dart';

class ShellScrollView extends StatelessWidget {
  const ShellScrollView({
    super.key,
    required this.child,
    this.controller,
    this.showFooter = true,
  });

  final Widget child;
  final ScrollController? controller;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(child: child),
        if (showFooter)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Align(alignment: Alignment.bottomCenter, child: AppFooter()),
          ),
      ],
    );
  }
}
