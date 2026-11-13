import 'package:itsqmet_mobile_pos/config/responsive/responsive.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/layout/shell_scroll_view.dart';
import 'package:material_ui/material_ui.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.maxWidth,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final double maxWidth;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ShellScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.pagePadding,
          vertical: AppSpacing.s12,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                context.atLeastSm ? AppSpacing.s10 : AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                border: Border.all(color: AppColors.emerald100),
                boxShadow: AppShadows.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AuthHeader(icon: icon, title: title, subtitle: subtitle),
                  AppSpacing.h24,
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

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.emerald100,
            borderRadius: AppRadius.lgAll,
            boxShadow: AppShadows.xs,
          ),
          child: Icon(icon, size: 22, color: AppColors.emerald800),
        ),
        AppSpacing.h12,
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.x2l.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.emerald950,
            letterSpacing: -0.6,
          ),
        ),
        AppSpacing.h4,
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.s3),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.s1,
        children: [
          Text(
            question,
            style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: AppRadius.smAll,
            child: Text(
              action,
              style: AppTextStyles.xs.copyWith(
                color: AppColors.emerald700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
