import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;

  final IconData? icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final stacked = !context.atLeastMd;
    final titleBlock = _TitleBlock(
      title: title,
      subtitle: subtitle,
      icon: icon,
    );
    final actionsWrap = Wrap(
      spacing: AppSpacing.s2,
      runSpacing: AppSpacing.s2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: actions,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.s6),
      padding: const EdgeInsets.only(bottom: AppSpacing.s6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.emerald100)),
      ),
      child: stacked
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleBlock,
                if (actions.isNotEmpty) ...[AppSpacing.h16, actionsWrap],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: titleBlock),
                if (actions.isNotEmpty) ...[AppSpacing.w16, actionsWrap],
              ],
            ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.title, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.emerald600,
              borderRadius: AppRadius.mdAll,
              boxShadow: AppShadows.xs,
            ),
            child: Icon(icon, size: 22, color: AppColors.white),
          ),
          AppSpacing.w12,
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.pageTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTextStyles.pageSubtitle),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
