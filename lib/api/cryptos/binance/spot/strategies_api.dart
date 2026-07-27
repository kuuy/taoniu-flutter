import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';
import 'package:taoniu/models/binance/spot/strategy.dart';

class StrategiesApi {
  static Future<PaginateResponse<Strategy>> listings({
    required String symbol,
    required String interval,
    int? signal,
    String? status,
    required int current,
    required int pageSize,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'interval': interval,
      'current': current,
      'page_size': pageSize,
    };
    if (signal != null) params['signal'] = signal;
    if (status != null && status.isNotEmpty) params['status'] = status;

    return ApiClient.paginate<Strategy>(
      '/api/cryptos/v1/binance/spot/strategies',
      queryParameters: params,
      fromJsonT: (json) => Strategy.fromJson(json),
    );
  }

  static Future<ApiResponse<List<Strategy>>> signals({
    required String symbol,
    required String interval,
  }) async {
    return ApiClient.get<List<Strategy>>(
      '/api/cryptos/v1/binance/spot/strategies/signals',
      queryParameters: {
        'symbol': symbol,
        'interval': interval,
      },
      fromJsonT: (json) => (json as List).map((e) => Strategy.fromJson(e)).toList(),
    );
  }
}

