library;

const double _epochSecondsLimit = 1e11;

final RegExp _numericString = RegExp(r'^-?\d+(\.\d+)?$');

DateTime? parseDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value.toLocal();
  if (value is num) return _fromEpoch(value);
  if (value is List) return _fromArray(value);
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    if (_numericString.hasMatch(text)) {
      final number = num.tryParse(text);
      return number == null ? null : _fromEpoch(number);
    }
    return DateTime.tryParse(text)?.toLocal();
  }
  return null;
}

DateTime? _fromEpoch(num value) {
  if (value is double && !value.isFinite) return null;
  if (value.abs() < _epochSecondsLimit) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    return DateTime.fromMicrosecondsSinceEpoch((value * 1e6).round());
  }
  return DateTime.fromMillisecondsSinceEpoch(value.round());
}

DateTime? _fromArray(List<dynamic> parts) {
  if (parts.length < 3) return null;
  final numbers = <int>[];
  for (final part in parts) {
    final number = parseInt(part);
    if (number == null) return null;
    numbers.add(number);
  }
  int at(int index) => index < numbers.length ? numbers[index] : 0;
  return DateTime(
    numbers[0],
    numbers[1],
    numbers[2],
    at(3),
    at(4),
    at(5),
    at(6) ~/ 1000000,
    (at(6) % 1000000) ~/ 1000,
  );
}

double? parseDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final direct = double.tryParse(text);
    if (direct != null) return direct;
    if (!text.contains('.')) return double.tryParse(text.replaceAll(',', '.'));
  }
  return null;
}

int? parseInt(Object? value) {
  if (value is int) return value;
  if (value is double) return value.isFinite ? value.toInt() : null;
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }
  return null;
}

bool? parseBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
        return true;
      case 'false':
        return false;
    }
  }
  return null;
}

String? parseString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

T parseEnum<T>(
  Object? raw,
  T Function(String value) fromJson, {
  required T orElse,
}) {
  if (raw is! String) return orElse;
  try {
    return fromJson(raw);
  } on FormatException {
    return orElse;
  }
}

List<Map<String, dynamic>> asJsonMapList(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw FormatException(
      'Se esperaba un arreglo JSON y llegó: ${value.runtimeType}',
    );
  }
  return value.map(asJsonMap).toList(growable: false);
}

Map<String, dynamic> asJsonMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException(
    'Se esperaba un objeto JSON y llegó: ${value.runtimeType}',
  );
}
