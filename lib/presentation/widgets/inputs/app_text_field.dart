import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:itsqmet_mobile_pos/config/theme/theme.dart';
import 'package:itsqmet_mobile_pos/presentation/widgets/inputs/field_label.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.errorText,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.prefixIcon,
    this.enabled = true,
    this.autofocus = false,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final String? errorText;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;

  final IconData? prefixIcon;
  final bool enabled;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: _obscured ? 1 : widget.maxLines,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: AppTextStyles.xs.copyWith(color: AppColors.gray800),
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.errorText,
        errorMaxLines: 2,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: Icon(
                  widget.prefixIcon,
                  size: 16,
                  color: AppColors.gray400,
                ),
              ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscured ? 'Mostrar' : 'Ocultar',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.gray400,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(widget.label!, required: widget.required),
        field,
      ],
    );
  }
}
