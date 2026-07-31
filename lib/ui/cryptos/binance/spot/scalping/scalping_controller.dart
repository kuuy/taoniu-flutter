import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/scalping_api.dart';
import 'package:taoniu/models/binance/spot/scalping.dart';

class ScalpingController extends GetxController {
  var items = <Scalping>[].obs;
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var selectedSymbol = 'ALL'.obs;
  var selectedSide = 'ALL'.obs; // ALL, BUY, SELL

  int _currentPage = 1;
  static const int _pageSize = 20;

  final symbols = const ['ALL', 'BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT'];
  final sides = const ['ALL', 'BUY', 'SELL'];

  @override
  void onInit() {
    super.onInit();
    fetchScalping(isRefresh: true);
  }

  Future<void> fetchScalping({bool isRefresh = true}) async {
    if (isRefresh) {
      _currentPage = 1;
      isLoading(true);
    }

    try {
      final symbolQuery = selectedSymbol.value == 'ALL' ? 'BTCUSDT' : selectedSymbol.value;
      int? sideQuery;
      if (selectedSide.value == 'BUY') sideQuery = 1;
      if (selectedSide.value == 'SELL') sideQuery = 2;

      final response = await ScalpingApi.listings(
        symbol: symbolQuery,
        side: sideQuery,
        current: _currentPage,
        pageSize: _pageSize,
      );

      final newItems = response.data ?? [];
      if (isRefresh) {
        items.assignAll(newItems);
      } else {
        items.addAll(newItems);
      }
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar('数据请求失败', e.toString(), snackPosition: SnackPosition.TOP);
      }
    } finally {
      isLoading(false);
      isRefreshing(false);
    }
  }

  void changeSymbol(String symbol) {
    if (selectedSymbol.value == symbol) return;
    selectedSymbol.value = symbol;
    fetchScalping(isRefresh: true);
  }

  void changeSide(String side) {
    if (selectedSide.value == side) return;
    selectedSide.value = side;
    fetchScalping(isRefresh: true);
  }

  Future<void> loadMore() async {
    _currentPage++;
    await fetchScalping(isRefresh: false);
  }
}
