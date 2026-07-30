import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taoniu/http/jwt_api.dart';
import 'package:taoniu/utils/jwe.dart';

class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  factory TokenRefreshService() => _instance;
  TokenRefreshService._internal();

  Timer? _timer;
  final JwtApi _jwtApi = JwtApi();

  void startAutoRefresh({Duration interval = const Duration(minutes: 15)}) {
    stopAutoRefresh();
    _timer = Timer.periodic(interval, (_) async {
      await refreshToken();
    });
    if (kDebugMode) {
      print('TokenRefreshService: Auto-refresh timer started (interval: ${interval.inMinutes}m)');
    }
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString("REFRESH_TOKEN");
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _jwtApi.refresh();
      if (response.statusCode == 200 && response.data != null) {
        dynamic jsonData = response.data;
        if (jsonData is String) {
          final str = jsonData.trim();
          if (JweUtil.isJweCompact(str)) {
            jsonData = jsonDecode(await JweUtil.decrypt(str));
          } else if (str.isNotEmpty) {
            jsonData = jsonDecode(str);
          }
        }

        if (jsonData is Map && jsonData['success'] == true && jsonData['data'] != null) {
          final dataMap = jsonData['data'];
          if (dataMap['access_token'] != null) {
            await prefs.setString('ACCESS_TOKEN', dataMap['access_token']);
          }
          if (dataMap['refresh_token'] != null) {
            await prefs.setString('REFRESH_TOKEN', dataMap['refresh_token']);
          }
          if (kDebugMode) {
            print('TokenRefreshService: Token refreshed successfully at ${DateTime.now()}');
          }
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('TokenRefreshService: Token refresh failed: $e');
      }
    }
    return false;
  }
}
