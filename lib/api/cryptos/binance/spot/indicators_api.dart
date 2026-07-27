import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';

class IndicatorsApi {
  static Future<ApiResponse<List<String>>> gets({
    required String symbols,
    required String interval,
    required String fields,
  }) async {
    return ApiClient.get<List<String>>(
      '/api/cryptos/v1/binance/spot/indicators',
      queryParameters: {
        'symbols': symbols,
        'interval': interval,
        'fields': fields,
      },
      fromJsonT: (json) => (json as List).map((e) => e.toString()).toList(),
    );
  }
}
