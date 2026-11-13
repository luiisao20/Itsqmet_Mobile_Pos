import 'package:material_ui/material_ui.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/app_text_field.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Buscar...',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint,
      prefixIcon: Icons.search,
      autofocus: autofocus,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
