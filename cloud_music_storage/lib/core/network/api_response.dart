/// Generic API response wrapper with pagination support.
library;

class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    this.message,
    this.pagination,
  });

  final T data;
  final String? message;
  final PaginationMeta? pagination;
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  final List<T> items;
  final PaginationMeta pagination;

  bool get hasMore => pagination.page < pagination.totalPages;
  int get nextPage => pagination.page + 1;
}

class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}
