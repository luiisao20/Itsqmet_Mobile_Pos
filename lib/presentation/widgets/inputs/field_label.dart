import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s1),
      child: Text.rich(
        TextSpan(
          text: label,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.rose600),
              ),
          ],
        ),
        style: AppTextStyles.label,
      ),
    );
  }
}
