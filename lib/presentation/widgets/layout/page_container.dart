import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/shell_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

class PageContainer extends StatelessWidget {
  const PageContainer({
    super.key,
    required this.child,
    this.scrollable = true,
    this.showFooter = true,
    this.controller,
    this.maxWidth = Breakpoints.xl,
    this.verticalPadding = AppSpacing.pageVertical,
  });

  final Widget child;
  final bool scrollable;
  final bool showFooter;
  final ScrollController? controller;
  final double maxWidth;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.pagePadding,
            vertical: verticalPadding,
          ),
          child: child,
        ),
      ),
    );

    if (!scrollable) return content;

    return ShellScrollView(
      controller: controller,
      showFooter: showFooter,
      child: content,
    );
  }
}
