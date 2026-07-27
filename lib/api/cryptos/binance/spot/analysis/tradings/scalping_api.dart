import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';
import 'package:taoniu/models/binance/spot/analysis/tradings/scalping.dart';

class ScalpingApi {
  static Future<PaginateResponse<Scalping>> listings({
    required int current,
    required int pageSize,
  }) async {
    return ApiClient.paginate<Scalping>(
      '/api/cryptos/v1/binance/spot/analysis/tradings/scalping',
      queryParameters: {
        'current': current,
        'page_size': pageSize,
      },
      fromJsonT: (json) => Scalping.fromJson(json),
    );
  }
}
