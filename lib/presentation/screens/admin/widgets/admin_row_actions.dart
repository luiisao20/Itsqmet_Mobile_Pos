import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/modals/confirm_dialog.dart';
import 'package:material_ui/material_ui.dart';

Future<bool> confirmAdminDelete(BuildContext context, String message) =>
    showConfirmDialog(
      context,
      title: 'Confirmar eliminación',
      message: message,
      confirmLabel: 'Eliminar',
      danger: true,
    );

class AdminRowActions extends StatelessWidget {
  const AdminRowActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionChip(
          label: 'Editar',
          background: AppColors.emerald50,
          pressed: AppColors.emerald100,
          foreground: AppColors.emerald800,
          onTap: onEdit,
        ),
        AppSpacing.w4,
        _ActionChip(
          label: 'Eliminar',
          background: AppColors.red50,
          pressed: AppColors.red100,
          foreground: AppColors.red600,
          onTap: onDelete,
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.background,
    required this.pressed,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color pressed;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        highlightColor: pressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: AppTextStyles.xs.copyWith(
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
