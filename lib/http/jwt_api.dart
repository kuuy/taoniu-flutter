import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/jwe.dart';
import 'dio_client.dart';
import 'api_service.dart';

class JwtApi {
  final Dio _dio = DioClient().dio;

  Future<Response> signIn({required String email, required String password}) async {
    // Hash password with MD5
    final hashedPassword = md5.convert(utf8.encode(password)).toString();

    // Create JSON payload
    final payloadJson = jsonEncode({
      "email": email,
      "password": hashedPassword,
    });

    // Encrypt payload with JWE
    final encryptedPayload = await JweUtil.encrypt(payloadJson);

    // Post to login endpoint
    return await _dio.post(
      '${ApiService.baseUrl}/api/account/v1/login',
      data: encryptedPayload,
      options: Options(
        contentType: 'application/octet-stream',
        responseType: ResponseType.plain,
      ),
    );
  }

  Future<Response> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString("REFRESH_TOKEN") ?? "";

    final payloadJson = jsonEncode({
      "refresh_token": refreshToken,
    });

    final encryptedPayload = await JweUtil.encrypt(payloadJson);

    return await _dio.post(
      '${ApiService.baseUrl}/api/account/v1/token/refresh',
      data: encryptedPayload,
      options: Options(
        contentType: 'application/octet-stream',
        responseType: ResponseType.plain,
      ),
    );
  }
}
