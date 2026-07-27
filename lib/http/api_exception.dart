import 'package:dio/dio.dart';

/// Base class for all API exceptions in Taoniu App.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => message;
}

/// Network level errors (no connection, timeout, unreachable host)
class NetworkException extends ApiException {
  final DioExceptionType? type;

  NetworkException(super.message, {this.type, super.statusCode, super.originalError});
}

/// Authorization & authentication errors (401, 403, expired token)
class UnauthenticatedException extends ApiException {
  UnauthenticatedException([super.message = '身份认证已过期，请重新登录', int? statusCode = 401, dynamic originalError])
      : super(statusCode: statusCode, originalError: originalError);
}

/// Server side errors (500, 502, 503, 504)
class ServerException extends ApiException {
  ServerException([super.message = '服务器响应异常，请稍后再试', int? statusCode = 500, dynamic originalError])
      : super(statusCode: statusCode, originalError: originalError);
}

/// Business logic errors returned by API (success: false)
class BusinessException extends ApiException {
  final String? code;

  BusinessException(super.message, {this.code, super.statusCode, super.originalError});
}

/// JWE decryption or JSON deserialization errors
class DecryptException extends ApiException {
  DecryptException([super.message = '数据解密或解析失败', int? statusCode, dynamic originalError])
      : super(statusCode: statusCode, originalError: originalError);
}
