import 'package:dio/dio.dart';
import 'dio_client.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio = DioClient().dio;

  // Read the base URL from the .env file
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  ApiService() {
    _dio.options.baseUrl = baseUrl;
  }

  // Example: Login endpoint
  Future<Response> login(String username, String password) async {
    return await _dio.post('/api/v1/auth/login', data: {
      'username': username,
      'password': password,
    });
  }

  // Example: Fetch market tickers
  Future<Response> getTickers() async {
    return await _dio.get('/api/v1/markets/tickers');
  }

  // Example: Fetch plans
  Future<Response> getPlans() async {
    return await _dio.get('/api/v1/plans');
  }
}
