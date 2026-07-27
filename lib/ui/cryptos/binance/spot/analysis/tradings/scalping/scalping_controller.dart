import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/analysis/tradings/scalping_api.dart';
import 'package:taoniu/models/binance/spot/analysis/tradings/scalping.dart';

class AnalysisTradingsScalpingController extends GetxController {
  final isLoading = false.obs;
  final scalpingList = <Scalping>[].obs;
  final totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchListings();
  }

  Future<void> fetchListings() async {
    isLoading.value = true;
    try {
      final response = await ScalpingApi.listings(current: 1, pageSize: 50);
      if (response.success) {
        scalpingList.assignAll(response.data ?? []);
        totalCount.value = response.total ?? 0;
      } else {
        Get.snackbar('Error', response.error ?? 'Failed to fetch listings');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
