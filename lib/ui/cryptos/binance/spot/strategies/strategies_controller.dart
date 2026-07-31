import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/strategies_api.dart';
import 'package:taoniu/models/cryptos/binance/spot/strategy.dart';

class StrategiesController extends GetxController {
  var items = <Strategy>[].obs;
  var isLoading = true.obs;
  var selectedInterval = '1m'.obs;
  final strategiesData = <String, List<Strategy>>{}.obs;

  final searchQuery = ''.obs;
  final selectedSignal = 'ALL'.obs; // ALL, BUY, SELL

  final intervals = ['1m', '15m', '4h', '1d'];
  final signals = const ['ALL', 'BUY', 'SELL'];
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    final initialIndex = intervals.indexOf(selectedInterval.value);
    pageController = PageController(initialPage: initialIndex >= 0 ? initialIndex : 0);
    fetchStrategies();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changeSignal(String sig) {
    selectedSignal.value = sig;
  }

  List<Strategy> getFilteredData(String interval) {
    var rawList = strategiesData[interval] ?? [];
    final q = searchQuery.value.trim().toUpperCase();

    if (selectedSignal.value == 'BUY') {
      rawList = rawList.where((s) => s.isBuy).toList();
    } else if (selectedSignal.value == 'SELL') {
      rawList = rawList.where((s) => s.isSell).toList();
    }

    if (q.isNotEmpty) {
      rawList = rawList.where((s) => s.symbol.toUpperCase().contains(q)).toList();
    }

    return rawList;
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
    fetchStrategies();
  }

  void onPageChanged(int index) {
    if (index < 0 || index >= intervals.length) return;
    final interval = intervals[index];
    if (selectedInterval.value != interval) {
      selectedInterval.value = interval;
      fetchStrategies();
    }
  }

  void fetchStrategies() async {
    final currentIntv = selectedInterval.value;
    try {
      if (!strategiesData.containsKey(currentIntv)) {
        isLoading(true);
      }
      final response = await StrategiesApi.listings(
        symbol: '',
        interval: currentIntv,
        current: 1,
        pageSize: 50,
      );
      strategiesData[currentIntv] = response.data ?? [];
      items.value = strategiesData[currentIntv] ?? [];
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar('获取策略数据失败', e.toString());
      }
    } finally {
      isLoading(false);
    }
  }
}
