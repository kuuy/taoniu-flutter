import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';
import 'package:taoniu/models/binance/spot/gambling_calc.dart';

class GamblingApi {
  static Future<ApiResponse<GamblingCalcResult>> calc({
    required String symbol,
    int? side,
    double? entryPrice,
    double? entryQuantity,
  }) async {
    final Map<String, dynamic> params = {
      'symbol': symbol,
    };
    if (side != null) params['side'] = side;
    if (entryPrice != null && entryPrice > 0) params['entry_price'] = entryPrice;
    if (entryQuantity != null && entryQuantity > 0) params['entry_quantity'] = entryQuantity;

    return ApiClient.get<GamblingCalcResult>(
      '/api/cryptos/v1/binance/spot/gambling/calc',
      queryParameters: params,
      fromJsonT: (json) => GamblingCalcResult.fromJson(json as Map<String, dynamic>),
      showErrorToast: true,
    );
  }
}
