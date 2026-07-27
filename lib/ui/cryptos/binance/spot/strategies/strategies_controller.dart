import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/strategies_api.dart';
import 'package:taoniu/models/binance/spot/strategy.dart';

class StrategiesController extends GetxController {
  var items = <Strategy>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStrategies();
  }

  void fetchStrategies() async {
    try {
      isLoading(true);
      final response = await StrategiesApi.listings(
        symbol: 'BTCUSDT',
        interval: '1m',
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
