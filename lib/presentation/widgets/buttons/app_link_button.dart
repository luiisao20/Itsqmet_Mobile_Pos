import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

class AppLinkButton extends StatelessWidget {
  const AppLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;

  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered)
              ? AppColors.emerald800
              : AppColors.emerald700,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
        textStyle: WidgetStatePropertyAll(
          AppTextStyles.xs.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            Icon(leading, size: 14),
            const SizedBox(width: 4),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
