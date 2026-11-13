import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

abstract final class NotificationsService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static const Duration _duration = Duration(seconds: 4);

  static void showSuccess(String message) => _show(
    message,
    icon: Icons.check_circle_outline,
    background: AppColors.emerald50,
    border: AppColors.emerald300,
    foreground: AppColors.emerald900,
  );

  static void showError(String message) => _show(
    message,
    icon: Icons.warning_amber_rounded,
    background: AppColors.rose50,
    border: AppColors.rose200,
    foreground: AppColors.rose700,
  );

  static void showInfo(String message) => _show(
    message,
    icon: Icons.info_outline,
    background: AppColors.sky50,
    border: AppColors.sky200,
    foreground: AppColors.sky800,
  );

  static void _show(
    String message, {
    required IconData icon,
    required Color background,
    required Color border,
    required Color foreground,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: _duration,
          elevation: 0,
          backgroundColor: background,
          margin: const EdgeInsets.all(AppSpacing.s4),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: BorderSide(color: border),
          ),
          content: Row(
            children: [
              Icon(icon, size: 18, color: foreground),
              AppSpacing.w8,
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.xs.copyWith(
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
