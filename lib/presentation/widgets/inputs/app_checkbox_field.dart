import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';

class AppCheckboxField extends StatelessWidget {
  const AppCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final callback = onChanged;
    return InkWell(
      borderRadius: AppRadius.smAll,
      onTap: callback == null ? null : () => callback(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                activeColor: AppColors.emerald600,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: callback == null
                    ? null
                    : (checked) => callback(checked ?? false),
              ),
            ),
            AppSpacing.w8,
            Expanded(child: Text(label, style: AppTextStyles.label)),
          ],
        ),
      ),
    );
  }
}
