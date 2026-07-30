import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/indicators/ranking_api.dart';

class IndicatorsRankingController extends GetxController {
  var items = <String>[].obs;
  var isLoading = true.obs;
  var selectedInterval = '1m'.obs;
  final rankingData = <String, List<String>>{}.obs;

  final intervals = ['1m', '15m', '4h', '1d'];
  late PageController pageController;

  final fields = [
    "r1",
    "s1",
    "poc",
    "vah",
    "val",
    "poc_ratio",
    "profit_target",
    "stop_loss_point",
    "risk_reward_ratio",
    "take_profit_ratio",
  ];

  @override
  void onInit() {
    super.onInit();
    final initialIndex = intervals.indexOf(selectedInterval.value);
    pageController = PageController(initialPage: initialIndex >= 0 ? initialIndex : 0);
    fetchRanking();
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
    fetchRanking();
  }

  void onPageChanged(int index) {
    if (index < 0 || index >= intervals.length) return;
    final interval = intervals[index];
    if (selectedInterval.value != interval) {
      selectedInterval.value = interval;
      fetchRanking();
    }
  }

  void fetchRanking() async {
    final currentIntv = selectedInterval.value;
    try {
      if (!rankingData.containsKey(currentIntv)) {
        isLoading(true);
      }
      final response = await IndicatorsRankingApi.ranking(
        symbols: "",
        interval: currentIntv,
        fields: fields.join(','),
        sort: "poc_ratio,-1",
        current: 1,
        pageSize: 100,
      );
      rankingData[currentIntv] = response.data ?? [];
      items.value = rankingData[currentIntv] ?? [];
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
