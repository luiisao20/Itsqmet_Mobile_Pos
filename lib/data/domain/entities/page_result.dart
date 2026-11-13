import 'package:equatable/equatable.dart';

class PageResult<T> extends Equatable {
  const PageResult({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory PageResult.single(List<T> content) => PageResult<T>(
    content: content,
    totalElements: content.length,
    totalPages: content.isEmpty ? 0 : 1,
    number: 0,
    size: content.length,
    first: true,
    last: true,
    empty: content.isEmpty,
  );

  final List<T> content;
  final int totalElements;
  final int totalPages;

  final int number;
  final int size;
  final bool first;
  final bool last;
  final bool empty;

  bool get hasNext => !last;

  PageResult<R> map<R>(R Function(T item) transform) => PageResult<R>(
    content: content.map(transform).toList(growable: false),
    totalElements: totalElements,
    totalPages: totalPages,
    number: number,
    size: size,
    first: first,
    last: last,
    empty: empty,
  );

  @override
  List<Object?> get props => [
    content,
    totalElements,
    totalPages,
    number,
    size,
    first,
    last,
    empty,
  ];
}
