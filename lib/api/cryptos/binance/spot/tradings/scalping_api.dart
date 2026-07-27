import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';
import 'package:taoniu/models/binance/spot/tradings/scalping.dart';

class ScalpingApi {
  static Future<PaginateResponse<TradingInfo>> listings({
    required String symbol,
    int? side,
    String? status,
    required int current,
    required int pageSize,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'current': current,
      'page_size': pageSize,
    };
    if (side != null) params['side'] = side;
    if (status != null) params['status'] = status;

    return ApiClient.paginate<TradingInfo>(
      '/api/cryptos/v1/binance/spot/tradings/scalping',
      queryParameters: params,
      fromJsonT: (json) => TradingInfo.fromJson(json),
    );
  }
}
