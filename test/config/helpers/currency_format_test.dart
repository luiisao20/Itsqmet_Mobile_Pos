import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/helpers/currency_format.dart';

void main() {
  group('CurrencyFormat.format', () {
    test('prefixes a dollar sign and uses two decimals', () {
      expect(CurrencyFormat.format(12.5), r'$12.50');
    });

    test('formats integers with two decimals', () {
      expect(CurrencyFormat.format(3), r'$3.00');
    });

    test('formats zero', () {
      expect(CurrencyFormat.format(0), r'$0.00');
    });

    test('rounds to two decimals', () {
      expect(CurrencyFormat.format(1.006), r'$1.01');
      expect(CurrencyFormat.format(1.234), r'$1.23');
    });

    test('does not add thousands separators (like toFixed(2) in the web)', () {
      expect(CurrencyFormat.format(1234.5), r'$1234.50');
    });

    test('places the minus sign before the dollar sign', () {
      expect(CurrencyFormat.format(-5), r'-$5.00');
    });
  });

  group('CurrencyFormat.plain', () {
    test('returns two decimals without symbol', () {
      expect(CurrencyFormat.plain(12.5), '12.50');
    });
  });
}
