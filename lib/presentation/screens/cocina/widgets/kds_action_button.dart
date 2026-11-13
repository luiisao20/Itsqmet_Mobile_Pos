import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

class KdsActionButton extends StatelessWidget {
  const KdsActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.pressedColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color pressedColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered)
              ? pressedColor
              : color,
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.white),
        iconColor: const WidgetStatePropertyAll(AppColors.white),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
        textStyle: WidgetStatePropertyAll(
          AppTextStyles.xs.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
