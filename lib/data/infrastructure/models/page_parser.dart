import 'package:itsqmet_mobile_pos/core/utils/json_parsers.dart';
import 'package:itsqmet_mobile_pos/data/domain/entities/page_result.dart';

PageResult<T> parsePage<T>(
  Object? json,
  T Function(Map<String, dynamic> json) item,
) {
  if (json == null) return PageResult<T>.single(const []);

  if (json is List) {
    return PageResult<T>.single(
      asJsonMapList(json).map(item).toList(growable: false),
    );
  }

  final map = asJsonMap(json);
  final content = asJsonMapList(map['content'])
      .map(item)
      .toList(growable: false);
  final number = parseInt(map['number']) ?? 0;
  final totalElements = parseInt(map['totalElements']) ?? content.length;
  final totalPages = parseInt(map['totalPages']) ?? (content.isEmpty ? 0 : 1);

  return PageResult<T>(
    content: content,
    totalElements: totalElements,
    totalPages: totalPages,
    number: number,
    size: parseInt(map['size']) ?? content.length,
    first: parseBool(map['first']) ?? number == 0,
    last: parseBool(map['last']) ?? number + 1 >= totalPages,
    empty: parseBool(map['empty']) ?? content.isEmpty,
  );
}
