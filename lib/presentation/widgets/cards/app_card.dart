import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s4),
    this.large = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  final bool large;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = large ? AppRadius.xlAll : AppRadius.lgAll;
    final content = Padding(padding: padding, child: child);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.emerald100),
        boxShadow: AppShadows.xs,
      ),
      child: onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, child: content),
            ),
    );
  }
}
