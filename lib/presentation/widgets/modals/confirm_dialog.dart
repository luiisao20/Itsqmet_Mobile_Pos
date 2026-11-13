import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/buttons/app_button.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/modals/app_modal.dart';
import 'package:material_ui/material_ui.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool danger = false,
}) async {
  final result = await showAppModal<bool>(
    context: context,
    title: title,
    body: Text(
      message,
      style: AppTextStyles.sm.copyWith(color: AppColors.gray700),
    ),
    footer: Builder(
      builder: (modalContext) => AppModalActions(
        children: [
          AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.outline,
            onPressed: () => closeAppModal(modalContext, false),
          ),
          AppButton(
            label: confirmLabel,
            variant: danger
                ? AppButtonVariant.danger
                : AppButtonVariant.primary,
            onPressed: () => closeAppModal(modalContext, true),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}
