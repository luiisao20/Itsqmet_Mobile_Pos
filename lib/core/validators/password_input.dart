import 'package:formz/formz.dart';

enum PasswordInputError { empty, tooShort }

class PasswordInput extends FormzInput<String, PasswordInputError> {
  const PasswordInput.pure({this.minLength = staffMinLength}) : super.pure('');

  const PasswordInput.dirty(super.value, {this.minLength = staffMinLength})
    : super.dirty();

  static const int staffMinLength = 4;

  static const int registerMinLength = 6;

  final int minLength;

  @override
  PasswordInputError? validator(String value) {
    if (value.isEmpty) return PasswordInputError.empty;
    return value.length < minLength ? PasswordInputError.tooShort : null;
  }

  String? get errorMessage => switch (displayError) {
    PasswordInputError.empty => 'La contraseña es obligatoria',
    PasswordInputError.tooShort =>
      'La contraseña debe tener al menos $minLength caracteres',
    null => null,
  };
}
