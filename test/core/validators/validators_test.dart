import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/validators/email_input.dart';
import 'package:itsqmet_mobile_pos/core/validators/number_inputs.dart';
import 'package:itsqmet_mobile_pos/core/validators/password_input.dart';
import 'package:itsqmet_mobile_pos/core/validators/required_input.dart';

void main() {
  group('EmailInput', () {
    test('is pure and shows no error initially', () {
      const input = EmailInput.pure();

      expect(input.isPure, isTrue);
      expect(input.errorMessage, isNull);
      expect(input.error, EmailInputError.empty);
    });

    test('empty dirty value is required', () {
      const input = EmailInput.dirty('   ');

      expect(input.error, EmailInputError.empty);
      expect(input.errorMessage, 'El correo es obligatorio');
    });

    test('rejects malformed emails', () {
      for (final value in ['abc', 'a@b', '@b.com', 'a b@c.com', 'a@b.']) {
        final input = EmailInput.dirty(value);
        expect(input.error, EmailInputError.invalid, reason: value);
        expect(input.errorMessage, 'Ingresa un correo válido');
      }
    });

    test('accepts valid emails (trimmed)', () {
      for (final value in [
        'a@b.com',
        ' mesero@itsqmet.edu.ec ',
        'x.y+z@d.io',
      ]) {
        final input = EmailInput.dirty(value);
        expect(input.isValid, isTrue, reason: value);
        expect(input.errorMessage, isNull);
      }
    });
  });

  group('RequiredInput', () {
    test('rejects blank values with a Spanish message', () {
      const input = RequiredInput.dirty('  ');

      expect(input.isValid, isFalse);
      expect(input.errorMessage, 'Este campo es obligatorio');
    });

    test('accepts non-blank values', () {
      const input = RequiredInput.dirty('Mesa 1');

      expect(input.isValid, isTrue);
      expect(input.errorMessage, isNull);
    });

    test('pure invalid input shows no message', () {
      const input = RequiredInput.pure();

      expect(input.isValid, isFalse);
      expect(input.errorMessage, isNull);
    });
  });

  group('PasswordInput', () {
    test('staff login requires at least 4 characters by default', () {
      expect(const PasswordInput.dirty('').error, PasswordInputError.empty);
      expect(
        const PasswordInput.dirty('abc').error,
        PasswordInputError.tooShort,
      );
      expect(const PasswordInput.dirty('abcd').isValid, isTrue);
    });

    test('register uses a minimum of 6', () {
      const short = PasswordInput.dirty(
        '12345',
        minLength: PasswordInput.registerMinLength,
      );
      const ok = PasswordInput.dirty(
        '123456',
        minLength: PasswordInput.registerMinLength,
      );

      expect(short.error, PasswordInputError.tooShort);
      expect(
        short.errorMessage,
        'La contraseña debe tener al menos 6 caracteres',
      );
      expect(ok.isValid, isTrue);
    });

    test('empty message is Spanish', () {
      expect(
        const PasswordInput.dirty('').errorMessage,
        'La contraseña es obligatoria',
      );
    });

    test('does not trim the password', () {
      expect(const PasswordInput.dirty('    ').isValid, isTrue);
    });
  });

  group('PositiveNumberInput', () {
    test('accepts numbers above zero with dot or comma decimals', () {
      expect(const PositiveNumberInput.dirty('5').isValid, isTrue);
      expect(const PositiveNumberInput.dirty('0.01').isValid, isTrue);
      expect(const PositiveNumberInput.dirty('12,50').isValid, isTrue);
      expect(const PositiveNumberInput.dirty('12,50').number, 12.5);
    });

    test('rejects empty, non numeric, zero and negatives', () {
      expect(const PositiveNumberInput.dirty('').error, NumberInputError.empty);
      expect(
        const PositiveNumberInput.dirty('abc').error,
        NumberInputError.notANumber,
      );
      expect(
        const PositiveNumberInput.dirty('0').error,
        NumberInputError.outOfRange,
      );
      expect(
        const PositiveNumberInput.dirty('-3').error,
        NumberInputError.outOfRange,
      );
      expect(
        const PositiveNumberInput.dirty('0').errorMessage,
        'El valor debe ser mayor a 0',
      );
    });

    test('number is null when invalid', () {
      expect(const PositiveNumberInput.dirty('x').number, isNull);
    });
  });

  group('NonNegativeNumberInput', () {
    test('accepts zero and positives', () {
      expect(const NonNegativeNumberInput.dirty('0').isValid, isTrue);
      expect(const NonNegativeNumberInput.dirty('3.5').isValid, isTrue);
      expect(const NonNegativeNumberInput.dirty('3,5').number, 3.5);
    });

    test('rejects empty, non numeric and negatives', () {
      expect(
        const NonNegativeNumberInput.dirty(' ').error,
        NumberInputError.empty,
      );
      expect(
        const NonNegativeNumberInput.dirty('abc').error,
        NumberInputError.notANumber,
      );
      expect(
        const NonNegativeNumberInput.dirty('-1').error,
        NumberInputError.outOfRange,
      );
      expect(
        const NonNegativeNumberInput.dirty('-1').errorMessage,
        'El valor no puede ser negativo',
      );
    });
  });
}
