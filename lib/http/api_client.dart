import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';
import '../utils/jwe.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'api_service.dart';
import 'dio_client.dart';
import 'jwt_api.dart';

class ApiClient {
  static final Dio _dio = DioClient().dio;

  /// Main internal request handler with JWE decryption & structured ApiException mapping
  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isRetry = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('ACCESS_TOKEN') ?? '';

    final options = Options(
      method: method,
      headers: {
        'Authorization': 'Taoniu $accessToken',
      },
      responseType: ResponseType.plain, // JWE compact string response
    );

    try {
      final response = await _dio.request(
        '${ApiService.baseUrl}$path',
        queryParameters: queryParameters,
        data: data,
        options: options,
      );

      return await _parseAndDecryptResponse(response.data);
    } on DioException catch (e) {
      return await _handleDioException(
        e,
        method: method,
        path: path,
        queryParameters: queryParameters,
        data: data,
        isRetry: isRetry,
        prefs: prefs,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw DecryptException('数据解析异常: $e', null, e);
    }
  }

  /// Parses JWE encrypted response into `Map<String, dynamic>`
  static Future<Map<String, dynamic>> _parseAndDecryptResponse(dynamic rawData) async {
    if (rawData == null || rawData.toString().isEmpty) {
      throw DecryptException('服务器返回空响应');
    }

    try {
      final jweCompact = rawData.toString();
      final payload = await JweUtil.decrypt(jweCompact);
      final jsonMap = jsonDecode(payload);

      if (jsonMap is! Map<String, dynamic>) {
        throw DecryptException('数据格式有误，期待 JSON 对象');
      }

      return jsonMap;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw DecryptException('JWE 解密失败: $e', null, e);
    }
  }

  /// Maps DioException to appropriate ApiException subtype with automatic 401 refresh retry logic
  static Future<Map<String, dynamic>> _handleDioException(
    DioException e, {
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    required bool isRetry,
    required SharedPreferences prefs,
  }) async {
    final statusCode = e.response?.statusCode;

    // Handle 401 / 403 Authentication Errors & Auto Token Refresh
    if (!isRetry && (statusCode == 401 || statusCode == 403)) {
      try {
        final jwtApi = JwtApi();
        final refreshResponse = await jwtApi.refresh();
        final decryptedString = await JweUtil.decrypt(refreshResponse.data.toString());
        final jsonData = jsonDecode(decryptedString);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final dataMap = jsonData['data'];
          await prefs.setString('ACCESS_TOKEN', dataMap['access_token'] ?? '');
          if (dataMap['refresh_token'] != null) {
            await prefs.setString('REFRESH_TOKEN', dataMap['refresh_token']);
          }
          // Retry the original request once with new token
          return await _request(
            method,
            path,
            queryParameters: queryParameters,
            data: data,
            isRetry: true,
          );
        }
      } catch (refreshErr) {
        // Refresh token invalid or expired -> force logout
        await _handleForceLogout(prefs);
        throw UnauthenticatedException('登录状态过期，请重新登录', statusCode, refreshErr);
      }
    }

    // Try to extract backend error payload if present in response
    if (e.response?.data != null) {
      try {
        final jweCompact = e.response!.data.toString();
        final payload = await JweUtil.decrypt(jweCompact);
        final jsonMap = jsonDecode(payload);
        if (jsonMap is Map<String, dynamic>) {
          return jsonMap;
        }
      } catch (_) {}
    }

    // Map network errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException('网络连接超时，请检查网络设置', type: e.type, statusCode: statusCode, originalError: e);
      case DioExceptionType.connectionError:
        throw NetworkException('无法连接到服务器，请检查网络连接', type: e.type, statusCode: statusCode, originalError: e);
      case DioExceptionType.badResponse:
        if (statusCode != null && statusCode >= 500) {
          throw ServerException('服务器错误 ($statusCode)，请稍后再试', statusCode, e);
        }
        throw NetworkException('服务器响应异常 ($statusCode)', type: e.type, statusCode: statusCode, originalError: e);
      case DioExceptionType.cancel:
        throw NetworkException('请求已取消', type: e.type, statusCode: statusCode, originalError: e);
      default:
        throw NetworkException('网络请求发生未知异常: ${e.message}', type: e.type, statusCode: statusCode, originalError: e);
    }
  }

  /// Clears stored tokens and redirects user to Login page
  static Future<void> _handleForceLogout(SharedPreferences prefs) async {
    await prefs.remove('ACCESS_TOKEN');
    await prefs.remove('REFRESH_TOKEN');
    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Displays UI error notice via GetX snackbar
  static void notifyUser(ApiException exception) {
    if (Get.isSnackbarOpen == true) return;
    Get.snackbar(
      '网络请求提示',
      exception.message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E222D),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.orangeAccent),
    );
  }

  /// Perform GET request
  static Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    bool showErrorToast = false,
  }) async {
    try {
      final responseData = await _request('GET', path, queryParameters: queryParameters);
      final apiResponse = ApiResponse.fromJson(
        responseData,
        fromJsonT ?? (dynamic data) => data as T,
      );
      if (!apiResponse.success && showErrorToast && apiResponse.error != null) {
        notifyUser(BusinessException(apiResponse.error!));
      }
      return apiResponse;
    } on ApiException catch (e) {
      if (showErrorToast) notifyUser(e);
      return ApiResponse.failure(e.message, code: e.statusCode);
    }
  }

  /// Perform Paginated GET request
  static Future<PaginateResponse<T>> paginate<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    bool showErrorToast = false,
  }) async {
    try {
      final responseData = await _request('GET', path, queryParameters: queryParameters);
      final paginatedResponse = PaginateResponse.fromJson(
        responseData,
        fromJsonT ?? (dynamic data) => data as T,
      );
      if (!paginatedResponse.success && showErrorToast && paginatedResponse.error != null) {
        notifyUser(BusinessException(paginatedResponse.error!));
      }
      return paginatedResponse;
    } on ApiException catch (e) {
      if (showErrorToast) notifyUser(e);
      return PaginateResponse.failure(e.message);
    }
  }

  /// Perform POST request
  static Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    T Function(dynamic)? fromJsonT,
    bool showErrorToast = false,
  }) async {
    try {
      final responseData = await _request('POST', path, queryParameters: queryParameters, data: data);
      final apiResponse = ApiResponse.fromJson(
        responseData,
        fromJsonT ?? (dynamic data) => data as T,
      );
      if (!apiResponse.success && showErrorToast && apiResponse.error != null) {
        notifyUser(BusinessException(apiResponse.error!));
      }
      return apiResponse;
    } on ApiException catch (e) {
      if (showErrorToast) notifyUser(e);
      return ApiResponse.failure(e.message, code: e.statusCode);
    }
  }
}
