import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Cargando ...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            AppSpacing.h12,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.xs.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }
}
