import 'dart:convert';
import 'package:dio/dio.dart';
import '../utils/jwe.dart';
import 'api_exception.dart';

/// Dio Interceptor that transparently decrypts JWE compact responses
/// and converts server error payloads into structured json objects.
class JweInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.data != null && JweUtil.isJweCompact(response.data)) {
      try {
        final jweCompact = response.data.toString().trim();
        final decryptedPayload = await JweUtil.decrypt(jweCompact);
        final dynamic jsonData = jsonDecode(decryptedPayload);
        response.data = jsonData;
      } catch (e) {
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: DecryptException('JWE 解密响应失败: $e', response.statusCode, e),
          ),
        );
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final responseData = err.response?.data;
    if (responseData != null && JweUtil.isJweCompact(responseData)) {
      try {
        final jweCompact = responseData.toString().trim();
        final decryptedPayload = await JweUtil.decrypt(jweCompact);
        final dynamic jsonData = jsonDecode(decryptedPayload);
        err.response?.data = jsonData;
      } catch (_) {
        // Silently preserve original error if decryption fails for error payload
      }
    }
    handler.next(err);
  }
}
