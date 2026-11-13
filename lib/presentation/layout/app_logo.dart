import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.emerald600,
            borderRadius: AppRadius.mdAll,
            boxShadow: AppShadows.xs,
          ),
          child: const Icon(Icons.restaurant, size: 20, color: AppColors.white),
        ),
        AppSpacing.w8,
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                const TextSpan(
                  text: 'RESTAURANTE',
                  children: [
                    TextSpan(
                      text: 'POS',
                      style: TextStyle(color: AppColors.emerald600),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.logo.copyWith(height: 1.2),
              ),
              Text(
                'SISTEMA GASTRONÓMICO',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return logo;
    return InkWell(onTap: onTap, borderRadius: AppRadius.mdAll, child: logo);
  }
}
