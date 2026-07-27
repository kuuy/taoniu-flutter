class ApiResponse<T> {
  final bool success;
  final String? error;
  final T? data;
  final int? code;

  ApiResponse({
    required this.success,
    this.error,
    this.data,
    this.code,
  });

  bool get isSuccess => success && error == null;

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      error: json['error']?.toString(),
      code: json['code'] is int ? json['code'] : null,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  factory ApiResponse.failure(String errorMessage, {int? code}) {
    return ApiResponse(
      success: false,
      error: errorMessage,
      code: code,
    );
  }
}

class PaginateResponse<T> {
  final bool success;
  final String? error;
  final List<T>? data;
  final int? total;
  final int? current;
  final int? pageSize;

  PaginateResponse({
    required this.success,
    this.error,
    this.data,
    this.total,
    this.current,
    this.pageSize,
  });

  bool get isSuccess => success && error == null;

  factory PaginateResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    var dataList = json['data'] as List?;
    List<T>? mappedData;
    if (dataList != null) {
      mappedData = dataList.map((e) => fromJsonT(e)).toList();
    }

    return PaginateResponse(
      success: json['success'] ?? false,
      error: json['error']?.toString(),
      data: mappedData ?? [],
      total: json['total'] is int ? json['total'] : 0,
      current: json['current'] is int ? json['current'] : 1,
      pageSize: json['page_size'] is int ? json['page_size'] : 20,
    );
  }

  factory PaginateResponse.failure(String errorMessage) {
    return PaginateResponse(
      success: false,
      error: errorMessage,
      data: [],
      total: 0,
      current: 1,
      pageSize: 20,
    );
  }
}
