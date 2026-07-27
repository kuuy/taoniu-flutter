import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/plans_api.dart';
import 'package:taoniu/models/binance/spot/plan.dart';

class BinanceSpotPlansController extends GetxController {
  var items = <Plan>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  void fetchPlans() async {
    try {
      isLoading(true);
      final response = await PlansApi.listings(
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
