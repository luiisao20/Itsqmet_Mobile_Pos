import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/enums/enums.dart';

void main() {
  group('parseDateTime', () {
    test('returns null for null, blank and garbage', () {
      expect(parseDateTime(null), isNull);
      expect(parseDateTime(''), isNull);
      expect(parseDateTime('   '), isNull);
      expect(parseDateTime('not a date'), isNull);
      expect(parseDateTime(true), isNull);
      expect(parseDateTime(<String, dynamic>{}), isNull);
    });

    test('parses ISO-8601 with Z and returns local time', () {
      final result = parseDateTime('2025-11-12T15:30:00Z')!;

      expect(result.isUtc, isFalse);
      expect(
        result.isAtSameMomentAs(DateTime.utc(2025, 11, 12, 15, 30)),
        isTrue,
      );
    });

    test('parses ISO-8601 with an offset', () {
      final result = parseDateTime('2025-11-12T10:30:00-05:00')!;

      expect(result.isUtc, isFalse);
      expect(
        result.isAtSameMomentAs(DateTime.utc(2025, 11, 12, 15, 30)),
        isTrue,
      );
    });

    test('parses a naive ISO-8601 as local time', () {
      final result = parseDateTime('2025-11-12T10:30:00')!;

      expect(result, DateTime(2025, 11, 12, 10, 30));
    });

    test('tolerates nanosecond fractions in ISO strings', () {
      final result = parseDateTime('2025-11-12T10:30:00.123456789')!;

      expect(result.year, 2025);
      expect(result.millisecond, 123);
    });

    test('treats small integers as epoch seconds', () {
      final result = parseDateTime(1731456000)!;

      expect(result.isUtc, isFalse);
      expect(result.isAtSameMomentAs(DateTime.utc(2024, 11, 13)), isTrue);
    });

    test('keeps fractional nanos of epoch seconds', () {
      final result = parseDateTime(1731456000.123456789)!;

      expect(result.millisecondsSinceEpoch, 1731456000123);
      expect(
        (result.microsecondsSinceEpoch - 1731456000123457).abs(),
        lessThanOrEqualTo(2),
      );
    });

    test('treats large integers as epoch milliseconds', () {
      final result = parseDateTime(1731456000123)!;

      expect(result.millisecondsSinceEpoch, 1731456000123);
    });

    test('uses 1e11 as the seconds/milliseconds boundary', () {
      expect(
        parseDateTime(99999999999)!.millisecondsSinceEpoch,
        99999999999000,
      );
      expect(parseDateTime(100000000000)!.millisecondsSinceEpoch, 100000000000);
    });

    test('accepts doubles with milliseconds magnitude', () {
      final result = parseDateTime(1731456000123.0)!;

      expect(result.millisecondsSinceEpoch, 1731456000123);
    });

    test('accepts numeric strings', () {
      expect(
        parseDateTime('1731456000')!.millisecondsSinceEpoch,
        1731456000000,
      );
      expect(
        parseDateTime('1731456000123')!.millisecondsSinceEpoch,
        1731456000123,
      );
      expect(
        parseDateTime('1731456000.5')!.millisecondsSinceEpoch,
        1731456000500,
      );
    });

    test('accepts the Jackson LocalDateTime array form', () {
      final result = parseDateTime([2025, 11, 12, 10, 30, 5, 123000000]);

      expect(result, DateTime(2025, 11, 12, 10, 30, 5, 123));
    });

    test('accepts a short array (date only)', () {
      expect(parseDateTime([2025, 11, 12]), DateTime(2025, 11, 12));
    });

    test('rejects malformed arrays', () {
      expect(parseDateTime([2025]), isNull);
      expect(parseDateTime(['a', 'b', 'c']), isNull);
    });

    test('passes a DateTime through as local time', () {
      final input = DateTime.utc(2025, 1, 2, 3);

      final result = parseDateTime(input)!;

      expect(result.isUtc, isFalse);
      expect(result.isAtSameMomentAs(input), isTrue);
    });
  });

  group('parseDouble', () {
    test('parses numbers and numeric strings', () {
      expect(parseDouble(12.5), 12.5);
      expect(parseDouble(3), 3.0);
      expect(parseDouble('12.50'), 12.5);
      expect(parseDouble(' 7 '), 7.0);
      expect(parseDouble('12,5'), 12.5);
    });

    test('returns null for null and garbage', () {
      expect(parseDouble(null), isNull);
      expect(parseDouble('abc'), isNull);
      expect(parseDouble(''), isNull);
      expect(parseDouble(true), isNull);
    });
  });

  group('parseInt', () {
    test('parses ints, integral doubles and numeric strings', () {
      expect(parseInt(5), 5);
      expect(parseInt(5.0), 5);
      expect(parseInt(5.7), 5);
      expect(parseInt('12'), 12);
      expect(parseInt(' 12 '), 12);
      expect(parseInt('12.0'), 12);
    });

    test('returns null for null and garbage', () {
      expect(parseInt(null), isNull);
      expect(parseInt('x'), isNull);
      expect(parseInt(''), isNull);
      expect(parseInt(double.nan), isNull);
      expect(parseInt(false), isNull);
    });
  });

  group('parseBool', () {
    test('parses bools, strings and numbers', () {
      expect(parseBool(true), isTrue);
      expect(parseBool(false), isFalse);
      expect(parseBool('true'), isTrue);
      expect(parseBool('TRUE'), isTrue);
      expect(parseBool(' false '), isFalse);
      expect(parseBool(1), isTrue);
      expect(parseBool(0), isFalse);
    });

    test('returns null for null and garbage', () {
      expect(parseBool(null), isNull);
      expect(parseBool('maybe'), isNull);
      expect(parseBool(<String>[]), isNull);
    });
  });

  group('parseString', () {
    test('returns strings as they are and stringifies scalars', () {
      expect(parseString('hola'), 'hola');
      expect(parseString(5), '5');
      expect(parseString(2.5), '2.5');
      expect(parseString(true), 'true');
    });

    test('returns null for null and structures', () {
      expect(parseString(null), isNull);
      expect(parseString(<String>[]), isNull);
      expect(parseString(<String, dynamic>{}), isNull);
    });
  });

  group('parseEnum', () {
    EstadoMesa parse(Object? raw) =>
        parseEnum(raw, EstadoMesa.fromJson, orElse: EstadoMesa.libre);

    test('maps known wire values', () {
      expect(parse('OCUPADA'), EstadoMesa.ocupada);
      expect(parse(' cuenta '), EstadoMesa.cuenta);
    });

    test('falls back for unknown values, null and non-strings', () {
      expect(parse('NUEVO_ESTADO'), EstadoMesa.libre);
      expect(parse(null), EstadoMesa.libre);
      expect(parse(3), EstadoMesa.libre);
    });
  });

  group('asJsonMapList', () {
    test('casts a list of objects', () {
      expect(
        asJsonMapList([
          {'a': 1},
          <dynamic, dynamic>{'b': 2},
        ]),
        [
          {'a': 1},
          {'b': 2},
        ],
      );
    });

    test('null is an empty list', () {
      expect(asJsonMapList(null), isEmpty);
    });

    test('throws a FormatException for non lists and non object items', () {
      expect(() => asJsonMapList('x'), throwsFormatException);
      expect(() => asJsonMapList({'a': 1}), throwsFormatException);
      expect(() => asJsonMapList([1]), throwsFormatException);
    });
  });

  group('asJsonMap', () {
    test('casts a Map with dynamic keys', () {
      final result = asJsonMap(<dynamic, dynamic>{'a': 1});

      expect(result, <String, dynamic>{'a': 1});
    });

    test('throws a FormatException for non-maps', () {
      expect(() => asJsonMap([1]), throwsFormatException);
      expect(() => asJsonMap(null), throwsFormatException);
    });
  });
}
