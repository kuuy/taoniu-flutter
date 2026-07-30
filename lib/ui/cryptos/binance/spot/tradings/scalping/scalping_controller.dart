import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/tradings/scalping_api.dart';
import 'package:taoniu/models/binance/spot/tradings/scalping.dart';

class TradingsScalpingController extends GetxController {
  var items = <TradingInfo>[].obs;
  var isLoading = true.obs;
  var selectedSymbol = 'ALL'.obs;

  int _currentPage = 1;
  static const int _pageSize = 20;

  final symbols = const ['ALL', 'BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT'];

  @override
  void onInit() {
    super.onInit();
    fetchListings(isRefresh: true);
  }

  Future<void> fetchListings({bool isRefresh = true}) async {
    if (isRefresh) {
      _currentPage = 1;
      isLoading(true);
    }

    try {
      final symbolQuery = selectedSymbol.value == 'ALL' ? 'BTCUSDT' : selectedSymbol.value;
      final response = await ScalpingApi.listings(
        symbol: symbolQuery,
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
      Get.snackbar('数据请求失败', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading(false);
    }
  }

  void changeSymbol(String symbol) {
    if (selectedSymbol.value == symbol) return;
    selectedSymbol.value = symbol;
    fetchListings(isRefresh: true);
  }

  Future<void> loadMore() async {
    _currentPage++;
    await fetchListings(isRefresh: false);
  }
}
