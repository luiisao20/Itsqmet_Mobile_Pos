import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

class SuccessBanner extends StatelessWidget {
  const SuccessBanner({
    super.key,
    required this.message,
    this.icon = Icons.celebration_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.emerald300),
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.emerald600),
          AppSpacing.w8,
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.xs.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.emerald900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
