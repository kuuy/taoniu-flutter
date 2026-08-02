import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';

class IndicatorsRankingApi {
  static Future<PaginateResponse<String>> ranking({
    String symbols = '',
    required String interval,
    required String fields,
    String sort = 'poc_ratio,-1',
    int current = 1,
    int pageSize = 200,
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
