import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';
import 'package:taoniu/models/binance/spot/position.dart';

class PositionsApi {
  static Future<ApiResponse<List<Position>>> gets() async {
    return ApiClient.get<List<Position>>(
      '/api/cryptos/v1/binance/spot/positions',
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => Position.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }
}
