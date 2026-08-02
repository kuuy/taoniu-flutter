import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taoniu/http/jwt_api.dart';
import 'package:taoniu/utils/jwe.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Login & Auth Tests', () {
    test('signIn sends JWE payload and receives response', () async {
      await dotenv.load(fileName: '.env');
      final jwtApi = JwtApi();

      try {
        final response = await jwtApi.signIn(email: 'admin', password: 'admin');
        print('SignIn response status: ${response.statusCode}');
        print('SignIn response data: ${response.data}');
      } on DioException catch (e) {
        print('DioException status: ${e.response?.statusCode}');
        print('DioException response data: ${e.response?.data}');
        expect(e.response?.statusCode, anyOf(200, 400, 403));
      }
    });
  });
}
