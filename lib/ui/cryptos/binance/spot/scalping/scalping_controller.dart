import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/scalping_api.dart';
import 'package:taoniu/models/binance/spot/scalping.dart';

class ScalpingController extends GetxController {
  var items = <Scalping>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchScalping();
  }

  void fetchScalping() async {
    try {
      isLoading(true);
      final response = await ScalpingApi.listings(
        symbol: 'BTCUSDT',
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
