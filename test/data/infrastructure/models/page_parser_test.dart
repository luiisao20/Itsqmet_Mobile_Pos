import 'package:flutter_test/flutter_test.dart';
import 'package:itsqmet_mobile_pos/data/infrastructure/models/page_parser.dart';

int _item(Map<String, dynamic> json) => json['v'] as int;

void main() {
  test('parses a Spring Page map', () {
    final page = parsePage<int>({
      'content': [
        {'v': 1},
        {'v': 2},
      ],
      'pageable': {'pageNumber': 1},
      'totalElements': 12,
      'totalPages': 6,
      'number': 1,
      'size': 2,
      'numberOfElements': 2,
      'first': false,
      'last': false,
      'empty': false,
    }, _item);

    expect(page.content, [1, 2]);
    expect(page.totalElements, 12);
    expect(page.totalPages, 6);
    expect(page.number, 1);
    expect(page.size, 2);
    expect(page.first, isFalse);
    expect(page.last, isFalse);
    expect(page.empty, isFalse);
    expect(page.hasNext, isTrue);
  });

  test('wraps a plain list as a single page', () {
    final page = parsePage<int>([
      {'v': 1},
      {'v': 2},
      {'v': 3},
    ], _item);

    expect(page.content, [1, 2, 3]);
    expect(page.totalElements, 3);
    expect(page.totalPages, 1);
    expect(page.number, 0);
    expect(page.first, isTrue);
    expect(page.last, isTrue);
    expect(page.empty, isFalse);
  });

  test('a Page map missing the metadata derives it from the content', () {
    final page = parsePage<int>({
      'content': [
        {'v': 1},
      ],
    }, _item);

    expect(page.content, [1]);
    expect(page.totalElements, 1);
    expect(page.totalPages, 1);
    expect(page.number, 0);
    expect(page.size, 1);
    expect(page.first, isTrue);
    expect(page.last, isTrue);
    expect(page.empty, isFalse);
  });

  test('metadata may arrive as strings', () {
    final page = parsePage<int>({
      'content': <Object?>[],
      'totalElements': '0',
      'totalPages': '0',
      'number': '0',
      'size': '10',
      'first': true,
      'last': true,
      'empty': true,
    }, _item);

    expect(page.content, isEmpty);
    expect(page.size, 10);
    expect(page.empty, isTrue);
  });

  test('null and a missing content become an empty page', () {
    expect(parsePage<int>(null, _item).empty, isTrue);
    expect(parsePage<int>(<String, dynamic>{}, _item).content, isEmpty);
    expect(parsePage<int>(<Object?>[], _item).empty, isTrue);
  });

  test('an empty Spring page keeps its own metadata', () {
    final page = parsePage<int>({
      'content': <Object?>[],
      'totalElements': 0,
      'totalPages': 0,
      'number': 0,
      'size': 20,
      'first': true,
      'last': true,
      'empty': true,
    }, _item);

    expect(page.totalPages, 0);
    expect(page.size, 20);
  });

  test('unsupported payloads throw a FormatException', () {
    expect(() => parsePage<int>('oops', _item), throwsFormatException);
    expect(
      () => parsePage<int>({'content': 'oops'}, _item),
      throwsFormatException,
    );
    expect(() => parsePage<int>([1, 2], _item), throwsFormatException);
  });
}
