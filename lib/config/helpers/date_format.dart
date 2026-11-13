import 'package:intl/intl.dart';

abstract final class AppDateFormat {
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _time = DateFormat('HH:mm');

  static String dateTime(DateTime value) => _dateTime.format(_local(value));

  static String date(DateTime value) => _date.format(_local(value));

  static String time(DateTime value) => _time.format(_local(value));

  static DateTime _local(DateTime value) =>
      value.isUtc ? value.toLocal() : value;
}
