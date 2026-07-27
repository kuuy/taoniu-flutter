import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/orders_api.dart';
import 'package:taoniu/models/binance/spot/order.dart';

class OrdersController extends GetxController {
  var items = <Order>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void fetchOrders() async {
    try {
      isLoading(true);
      final response = await OrdersApi.listings(
        symbol: 'BTCUSDT',
        positionSide: '',
        status: '',
        current: 1,
        pageSize: 50,
      );
      items.value = response.data ?? [];
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
