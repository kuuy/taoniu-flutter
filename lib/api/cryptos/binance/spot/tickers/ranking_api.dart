import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';

class TickersRankingApi {
  static Future<PaginateResponse<String>> ranking({
    String? symbols,
    required String fields,
    required String sort,
    required int current,
    required int pageSize,
  }) async {
    final params = <String, dynamic>{
      'fields': fields,
      'sort': sort,
      'current': current,
      'page_size': pageSize,
    };
    if (symbols != null && symbols.isNotEmpty) {
      params['symbols'] = symbols;
    }

    return ApiClient.paginate<String>(
      '/api/cryptos/v1/binance/spot/tickers/ranking',
      queryParameters: params,
      fromJsonT: (json) => json.toString(),
    );
  }
}
