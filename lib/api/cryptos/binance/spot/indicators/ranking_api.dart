import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';

class IndicatorsRankingApi {
  static Future<PaginateResponse<String>> ranking({
    required String symbols,
    required String interval,
    required String fields,
    required String sort,
    required int current,
    required int pageSize,
  }) async {
    return ApiClient.paginate<String>(
      '/api/cryptos/v1/binance/spot/indicators/ranking',
      queryParameters: {
        'symbols': symbols,
        'interval': interval,
        'fields': fields,
        'sort': sort,
        'current': current,
        'page_size': pageSize,
      },
      fromJsonT: (json) => json.toString(),
    );
  }
}
