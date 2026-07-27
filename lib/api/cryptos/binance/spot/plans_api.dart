import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/http/api_response.dart';
import 'package:taoniu/models/binance/spot/plan.dart';

class PlansApi {
  static Future<PaginateResponse<Plan>> listings({
    required String symbol,
    required String interval,
    int? side,
    String? status,
    required int current,
    required int pageSize,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'interval': interval,
      'current': current,
      'page_size': pageSize,
    };
    if (side != null) params['side'] = side;
    if (status != null && status.isNotEmpty) params['status'] = status;

    return ApiClient.paginate<Plan>(
      '/api/cryptos/v1/binance/spot/plans',
      queryParameters: params,
      fromJsonT: (json) => Plan.fromJson(json),
    );
  }
}
