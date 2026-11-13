import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/config/helpers/date_format.dart';

void main() {
  final value = DateTime(2026, 11, 5, 9, 7);

  group('AppDateFormat', () {
    test('dateTime uses dd/MM/yyyy HH:mm', () {
      expect(AppDateFormat.dateTime(value), '05/11/2026 09:07');
    });

    test('time uses HH:mm in 24 hour clock', () {
      expect(AppDateFormat.time(DateTime(2026, 1, 1, 18, 45)), '18:45');
    });

    test('date uses dd/MM/yyyy', () {
      expect(AppDateFormat.date(value), '05/11/2026');
    });

    test('converts UTC values to local time before formatting', () {
      final utc = DateTime.utc(2026, 11, 5, 14, 30);
      final local = utc.toLocal();
      final expected =
          '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';

      expect(AppDateFormat.time(utc), expected);
    });
  });
}
