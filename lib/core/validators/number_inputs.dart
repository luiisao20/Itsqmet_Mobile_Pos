import 'package:formz/formz.dart';

enum NumberInputError { empty, notANumber, outOfRange }

double? parseLocalizedNumber(String text) {
  final normalized = text.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

abstract class _NumberInput extends FormzInput<String, NumberInputError> {
  const _NumberInput.pure(super.value) : super.pure();

  const _NumberInput.dirty(super.value) : super.dirty();

  bool isInRange(double number);

  String get outOfRangeMessage;

  double? get number => parseLocalizedNumber(value);

  @override
  NumberInputError? validator(String value) {
    if (value.trim().isEmpty) return NumberInputError.empty;
    final parsed = parseLocalizedNumber(value);
    if (parsed == null) return NumberInputError.notANumber;
    return isInRange(parsed) ? null : NumberInputError.outOfRange;
  }

  String? get errorMessage => switch (displayError) {
    NumberInputError.empty => 'Ingresa un valor',
    NumberInputError.notANumber => 'Ingresa un número válido',
    NumberInputError.outOfRange => outOfRangeMessage,
    null => null,
  };
}

class PositiveNumberInput extends _NumberInput {
  const PositiveNumberInput.pure([super.value = '']) : super.pure();

  const PositiveNumberInput.dirty([super.value = '']) : super.dirty();

  @override
  bool isInRange(double number) => number > 0;

  @override
  String get outOfRangeMessage => 'El valor debe ser mayor a 0';
}

class NonNegativeNumberInput extends _NumberInput {
  const NonNegativeNumberInput.pure([super.value = '']) : super.pure();

  const NonNegativeNumberInput.dirty([super.value = '']) : super.dirty();

  @override
  bool isInRange(double number) => number >= 0;

  @override
  String get outOfRangeMessage => 'El valor no puede ser negativo';
}
