import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/indicators/ranking_api.dart';

class IndicatorsRankingController extends GetxController {
  var items = <String>[].obs;
  var isLoading = true.obs;
  var selectedInterval = '1m'.obs;

  final intervals = ['1m', '15m', '4h', '1d'];

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
    fetchRanking();
  }

  void setInterval(String interval) {
    if (selectedInterval.value == interval) return;
    selectedInterval.value = interval;
    fetchRanking();
  }

  void fetchRanking() async {
    try {
      isLoading(true);
      final response = await IndicatorsRankingApi.ranking(
        symbols: "",
        interval: selectedInterval.value,
        fields: fields.join(','),
        sort: "poc_ratio,-1",
        current: 1,
        pageSize: 100,
      );
      items.value = response.data ?? [];
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
