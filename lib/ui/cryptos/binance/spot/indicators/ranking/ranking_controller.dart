import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/indicators_api.dart';
import 'package:taoniu/api/cryptos/binance/spot/indicators/ranking_api.dart';

class IndicatorsRankingController extends GetxController {
  var items = <String>[].obs;
  var isLoading = true.obs;
  var selectedInterval = '1m'.obs;
  final rankingData = <String, List<String>>{}.obs;

  var btcAhr999 = RxnDouble();
  var btcMvrv = RxnDouble();

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

  final searchQuery = ''.obs;
  final sortFieldIndex = 5.obs; // Default to poc_ratio
  final sortAscending = false.obs;

  void clearSearch() {
    searchQuery.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    final initialIndex = intervals.indexOf(selectedInterval.value);
    pageController = PageController(initialPage: initialIndex >= 0 ? initialIndex : 0);
    fetchRanking();
    fetchBtc1dMetrics();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void toggleSort(int fieldIndex) {
    if (sortFieldIndex.value == fieldIndex) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortFieldIndex.value = fieldIndex;
      sortAscending.value = false;
    }
  }

  List<String> getFilteredData(String interval) {
    final rawList = rankingData[interval] ?? [];
    final q = searchQuery.value.trim().toUpperCase();

    var list = rawList.map((item) => item).toList();

    if (q.isNotEmpty) {
      list = list.where((item) {
        final symbol = item.split(',')[0].trim().toUpperCase();
        return symbol.contains(q);
      }).toList();
    }

    final fIdx = sortFieldIndex.value;
    list.sort((a, b) {
      final partsA = a.split(',');
      final partsB = b.split(',');

      final valAStr = (fIdx + 1 < partsA.length) ? partsA[fIdx + 1] : '';
      final valBStr = (fIdx + 1 < partsB.length) ? partsB[fIdx + 1] : '';

      final numA = double.tryParse(valAStr) ?? double.negativeInfinity;
      final numB = double.tryParse(valBStr) ?? double.negativeInfinity;

      final cmp = numA.compareTo(numB);
      return sortAscending.value ? cmp : -cmp;
    });

    return list;
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
    if (interval == '1d') {
      fetchBtc1dMetrics();
    }
  }

  void onPageChanged(int index) {
    if (index < 0 || index >= intervals.length) return;
    final interval = intervals[index];
    if (selectedInterval.value != interval) {
      selectedInterval.value = interval;
      fetchRanking();
      if (interval == '1d') {
        fetchBtc1dMetrics();
      }
    }
  }

  var btcPrice = RxnDouble();

  Future<void> fetchBtc1dMetrics() async {
    try {
      final response = await IndicatorsApi.gets(
        symbols: "BTCUSDT",
        interval: "1d",
        fields: "ahr999,mvrv",
      );
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        final parts = response.data![0].split(',');
        // response.data[0] format: "ahr999_val,price,timestamp,mvrv_val,price,timestamp"
        if (parts.isNotEmpty) btcAhr999.value = double.tryParse(parts[0]);
        if (parts.length > 1) btcPrice.value = double.tryParse(parts[1]);
        if (parts.length > 3) btcMvrv.value = double.tryParse(parts[3]);
      }
    } catch (_) {}
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchRanking(),
      fetchBtc1dMetrics(),
    ]);
  }

  Future<void> fetchRanking() async {
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
        pageSize: 200,
      );
      rankingData[currentIntv] = response.data ?? [];
      items.value = rankingData[currentIntv] ?? [];
    } catch (e) {
      if (Get.context != null) Get.snackbar('获取指标数据失败', e.toString());
    } finally {
      isLoading(false);
    }
  }
}

