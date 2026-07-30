import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';
import 'package:taoniu/models/binance/spot/position.dart';
import 'package:taoniu/models/binance/spot/position_calc.dart';

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

  static Future<ApiResponse<PositionCalcResult>> calc({
    required String symbol,
    required double maxCapital,
    required double entryPrice,
    required double entryQuantity,
  }) async {
    return ApiClient.get<PositionCalcResult>(
      '/api/cryptos/v1/binance/spot/positions/calc',
      queryParameters: {
        'symbol': symbol,
        'max_capital': maxCapital,
        'entry_price': entryPrice,
        'entry_quantity': entryQuantity,
      },
      fromJsonT: (json) => PositionCalcResult.fromJson(json as Map<String, dynamic>),
      showErrorToast: true,
    );
  }
}

