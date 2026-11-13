import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/field_label.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.errorText,
    this.required = false,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final field = InputDecorator(
      isEmpty: value == null,
      isFocused: false,
      decoration: InputDecoration(
        errorText: errorText,
        enabled: onChanged != null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          isDense: true,
          borderRadius: AppRadius.mdAll,
          dropdownColor: AppColors.white,
          style: AppTextStyles.xs.copyWith(color: AppColors.gray800),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.gray400,
          ),
          hint: hint == null
              ? null
              : Text(
                  hint!,
                  style: AppTextStyles.xs.copyWith(color: AppColors.gray400),
                ),
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label!, required: required),
        field,
      ],
    );
  }
}
