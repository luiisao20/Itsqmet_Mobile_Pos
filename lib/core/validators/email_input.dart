import 'package:formz/formz.dart';

enum EmailInputError { empty, invalid }

class EmailInput extends FormzInput<String, EmailInputError> {
  const EmailInput.pure([super.value = '']) : super.pure();

  const EmailInput.dirty([super.value = '']) : super.dirty();

  static final RegExp _pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  EmailInputError? validator(String value) {
    final text = value.trim();
    if (text.isEmpty) return EmailInputError.empty;
    return _pattern.hasMatch(text) ? null : EmailInputError.invalid;
  }

  String? get errorMessage => switch (displayError) {
    EmailInputError.empty => 'El correo es obligatorio',
    EmailInputError.invalid => 'Ingresa un correo válido',
    null => null,
  };
}
