import 'package:formz/formz.dart';

enum RequiredInputError { empty }

class RequiredInput extends FormzInput<String, RequiredInputError> {
  const RequiredInput.pure([super.value = '']) : super.pure();

  const RequiredInput.dirty([super.value = '']) : super.dirty();

  @override
  RequiredInputError? validator(String value) =>
      value.trim().isEmpty ? RequiredInputError.empty : null;

  String? get errorMessage => switch (displayError) {
    RequiredInputError.empty => 'Este campo es obligatorio',
    null => null,
  };
}
