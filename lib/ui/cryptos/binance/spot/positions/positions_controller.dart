import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/positions_api.dart';
import 'package:taoniu/models/binance/spot/position.dart';

class PositionsController extends GetxController {
  var items = <Position>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPositions();
  }

  void fetchPositions() async {
    try {
      isLoading(true);
      final response = await PositionsApi.gets();
      items.value = response.data ?? [];
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
