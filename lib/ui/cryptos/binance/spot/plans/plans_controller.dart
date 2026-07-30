import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/plans_api.dart';
import 'package:taoniu/models/binance/spot/plan.dart';

class BinanceSpotPlansController extends GetxController {
  var items = <Plan>[].obs;
  var isLoading = true.obs;
  var selectedInterval = '1m'.obs;
  final plansData = <String, List<Plan>>{}.obs;

  final intervals = ['1m', '15m', '4h', '1d'];
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    final initialIndex = intervals.indexOf(selectedInterval.value);
    pageController = PageController(initialPage: initialIndex >= 0 ? initialIndex : 0);
    fetchPlans();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void setInterval(String interval) {
    if (selectedInterval.value == interval) return;
    selectedInterval.value = interval;
    final index = intervals.indexOf(interval);
    if (index != -1 && pageController.hasClients && pageController.page?.round() != index) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    fetchPlans();
  }

  void onPageChanged(int index) {
    if (index < 0 || index >= intervals.length) return;
    final interval = intervals[index];
    if (selectedInterval.value != interval) {
      selectedInterval.value = interval;
      fetchPlans();
    }
  }

  void fetchPlans() async {
    final currentIntv = selectedInterval.value;
    try {
      if (!plansData.containsKey(currentIntv)) {
        isLoading(true);
      }
      final response = await PlansApi.listings(
        symbol: '',
        interval: currentIntv,
        current: 1,
        pageSize: 50,
      );
      plansData[currentIntv] = response.data ?? [];
      items.value = plansData[currentIntv] ?? [];
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
