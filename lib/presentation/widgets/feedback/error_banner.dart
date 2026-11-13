import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.rose50,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.rose200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.rose600,
          ),
          AppSpacing.w8,
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.xs.copyWith(color: AppColors.rose700),
            ),
          ),
        ],
      ),
    );
  }
}
