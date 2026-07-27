import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/tradings/scalping_api.dart';
import 'package:taoniu/models/binance/spot/tradings/scalping.dart';

class TradingsScalpingController extends GetxController {
  var items = <TradingInfo>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchListings();
  }

  void fetchListings() async {
    try {
      isLoading(true);
      final response = await ScalpingApi.listings(symbol: 'BTCUSDT', current: 1, pageSize: 50);
      items.value = response.data ?? [];
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
