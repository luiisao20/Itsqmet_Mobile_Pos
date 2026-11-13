import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.restaurant,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    final callback = onAction;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.emerald50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: AppColors.emerald600),
            ),
            AppSpacing.h12,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle.copyWith(color: AppColors.gray700),
            ),
            if (message != null) ...[
              AppSpacing.h4,
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
              ),
            ],
            if (label != null && callback != null) ...[
              AppSpacing.h16,
              AppButton(
                label: label,
                onPressed: callback,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.sm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
