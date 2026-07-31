import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';
import 'package:taoniu/models/cryptos/binance/spot/order.dart';

class OrdersApi {
  static Future<PaginateResponse<Order>> listings({
    required String symbol,
    required String positionSide,
    required String status,
    required int current,
    required int pageSize,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'position_side': positionSide,
      'status': status,
      'current': current,
      'page_size': pageSize,
    };

    return ApiClient.paginate<Order>(
      '/api/cryptos/v1/binance/spot/orders',
      queryParameters: params,
      fromJsonT: (json) => Order.fromJson(json),
    );
  }
}
