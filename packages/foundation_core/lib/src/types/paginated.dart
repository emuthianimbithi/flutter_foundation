import 'package:equatable/equatable.dart';

/// Represents a paginated response containing a list of items.
///
/// Example:
/// ```dart
/// final page = Paginated<User>(
///   items: users,
///   page: 1,
///   pageSize: 20,
///   totalItems: 150,
/// );
///
/// print(page.totalPages); // 8
/// print(page.hasNextPage); // true
/// print(page.hasPreviousPage); // false
/// ```
class Paginated<T> extends Equatable {
  /// The items in this page.
  final List<T> items;

  /// The current page number (1-indexed).
  final int page;

  /// The number of items per page.
  final int pageSize;

  /// The total number of items across all pages.
  final int totalItems;

  /// Optional cursor for cursor-based pagination.
  final String? nextCursor;

  /// Optional cursor for cursor-based pagination.
  final String? previousCursor;

  const Paginated({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    this.nextCursor,
    this.previousCursor,
  });

  /// Creates an empty paginated response.
  factory Paginated.empty({int pageSize = 20}) => Paginated(
        items: const [],
        page: 1,
        pageSize: pageSize,
        totalItems: 0,
      );

  /// Creates a single-page response containing all items.
  factory Paginated.single(List<T> items) => Paginated(
        items: items,
        page: 1,
        pageSize: items.length,
        totalItems: items.length,
      );

  /// The total number of pages.
  int get totalPages => (totalItems / pageSize).ceil();

  /// Whether there is a next page.
  bool get hasNextPage =>
      nextCursor != null || (page < totalPages && items.isNotEmpty);

  /// Whether there is a previous page.
  bool get hasPreviousPage => previousCursor != null || page > 1;

  /// Whether this is the first page.
  bool get isFirstPage => page == 1;

  /// Whether this is the last page.
  bool get isLastPage => page >= totalPages || items.isEmpty;

  /// Whether this page is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether this page has items.
  bool get isNotEmpty => items.isNotEmpty;

  /// The number of items in this page.
  int get length => items.length;

  /// The offset of the first item in this page (0-indexed).
  int get offset => (page - 1) * pageSize;

  /// Maps the items using [fn].
  Paginated<R> map<R>(R Function(T item) fn) => Paginated<R>(
        items: items.map(fn).toList(),
        page: page,
        pageSize: pageSize,
        totalItems: totalItems,
        nextCursor: nextCursor,
        previousCursor: previousCursor,
      );

  /// Creates a copy with modified properties.
  Paginated<T> copyWith({
    List<T>? items,
    int? page,
    int? pageSize,
    int? totalItems,
    String? nextCursor,
    String? previousCursor,
  }) =>
      Paginated<T>(
        items: items ?? this.items,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        totalItems: totalItems ?? this.totalItems,
        nextCursor: nextCursor ?? this.nextCursor,
        previousCursor: previousCursor ?? this.previousCursor,
      );

  @override
  List<Object?> get props => [
        items,
        page,
        pageSize,
        totalItems,
        nextCursor,
        previousCursor,
      ];

  @override
  String toString() =>
      'Paginated(page: $page/$totalPages, items: ${items.length}, total: $totalItems)';
}

/// Pagination parameters for requests.
class PaginationParams extends Equatable {
  /// The page number to fetch (1-indexed).
  final int page;

  /// The number of items per page.
  final int pageSize;

  /// Optional cursor for cursor-based pagination.
  final String? cursor;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.cursor,
  });

  /// Creates the first page params.
  factory PaginationParams.first({int pageSize = 20}) =>
      PaginationParams(page: 1, pageSize: pageSize);

  /// Creates params for the next page.
  PaginationParams nextPage() => copyWith(page: page + 1);

  /// Creates params for the previous page.
  PaginationParams previousPage() =>
      copyWith(page: page > 1 ? page - 1 : 1);

  /// Creates params with a cursor.
  PaginationParams withCursor(String cursor) =>
      copyWith(cursor: cursor);

  /// The offset for offset-based pagination.
  int get offset => (page - 1) * pageSize;

  /// Creates a copy with modified properties.
  PaginationParams copyWith({
    int? page,
    int? pageSize,
    String? cursor,
  }) =>
      PaginationParams(
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        cursor: cursor ?? this.cursor,
      );

  /// Converts to a map for query parameters.
  Map<String, dynamic> toQueryParams() => {
        'page': page,
        'page_size': pageSize,
        if (cursor != null) 'cursor': cursor,
      };

  @override
  List<Object?> get props => [page, pageSize, cursor];
}
