import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';
import 'package:taoniu/models/binance/spot/kline.dart';

class KlinesApi {
  static final Dio _publicDio = Dio();

  static Future<ApiResponse<List<Kline>>> fetch({
    required String symbol,
    required String interval,
    int? limit,
    int? startTime,
    int? endTime,
  }) async {
    final cleanSymbol = symbol.replaceAll('BINANCE:', '').toUpperCase();
    final binanceInterval = normalizeInterval(interval);

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('ACCESS_TOKEN') ?? '';

    if (accessToken.isNotEmpty) {
      try {
        final params = <String, dynamic>{
          'symbol': cleanSymbol,
          'interval': binanceInterval,
        };
        if (limit != null) params['limit'] = limit;
        if (startTime != null) params['startTime'] = startTime;
        if (endTime != null) params['endTime'] = endTime;

        final response = await ApiClient.get<List<Kline>>(
          '/api/cryptos/v1/binance/spot/klines',
          queryParameters: params,
          fromJsonT: (json) => (json as List).map((e) => Kline.fromJson(e)).toList(),
        );

        if (response.success && response.data != null && response.data!.isNotEmpty) {
          return response;
        }
      } catch (_) {}
    }

    // Fallback to Binance Vision Public API when unauthenticated or status != 200
    try {
      final queryParams = <String, dynamic>{
        'symbol': cleanSymbol,
        'interval': binanceInterval,
        'limit': limit ?? 100,
      };
      if (startTime != null) queryParams['startTime'] = startTime;
      if (endTime != null) queryParams['endTime'] = endTime;

      final pubRes = await _publicDio.get(
        'https://data-api.binance.vision/api/v3/klines',
        queryParameters: queryParams,
      );

      if (pubRes.statusCode == 200 && pubRes.data is List) {
        final list = (pubRes.data as List).map((e) => Kline.fromJson(e)).toList();
        return ApiResponse<List<Kline>>(
          success: true,
          data: list,
        );
      }
    } catch (e) {
      return ApiResponse<List<Kline>>(
        success: false,
        error: 'Failed to load klines: $e',
      );
    }

    return ApiResponse<List<Kline>>(
      success: false,
      error: 'No klines available',
    );
  }

  static String normalizeInterval(String interval) {
    switch (interval.toLowerCase()) {
      case 'd':
      case '1d':
        return '1d';
      case '4h':
      case '240':
        return '4h';
      case '15m':
      case '15':
        return '15m';
      case '1m':
      case '1':
        return '1m';
      default:
        return '1d';
    }
  }

  static String toTradingViewResolution(String interval) {
    switch (interval.toLowerCase()) {
      case '1m':
      case '1':
        return '1';
      case '15m':
      case '15':
        return '15';
      case '4h':
      case '240':
        return '240';
      case 'd':
      case '1d':
      default:
        return 'D';
    }
  }
}
