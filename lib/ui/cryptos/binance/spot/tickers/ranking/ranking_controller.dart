import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/tickers/ranking_api.dart';

class TickersRankingController extends GetxController {
  var items = <String>[].obs;
  var isLoading = true.obs;

  final fields = [
    "price",
    "open",
    "high",
    "low",
    "volume",
    "quota",
    "change",
    "slippage_percent@1%",
    "slippage_percent@2%",
  ];

  @override
  void onInit() {
    super.onInit();
    fetchRanking();
  }

  void fetchRanking() async {
    try {
      isLoading(true);
      final response = await TickersRankingApi.ranking(
        symbols: "",
        fields: fields.join(','),
        sort: "change,-1",
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
