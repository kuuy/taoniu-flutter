import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/orders_api.dart';
import 'package:taoniu/models/binance/spot/order.dart';

class OrdersController extends GetxController {
  final items = <Order>[].obs;
  final isLoading = true.obs;
  final isTableView = true.obs;
  final searchQuery = ''.obs;

  final selectedSymbol = 'ALL'.obs;
  final selectedSide = 'ALL'.obs; // ALL, BUY, SELL

  final symbols = const ['ALL', 'BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT'];
  final sides = const ['ALL', 'BUY', 'SELL'];

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void toggleViewMode() {
    isTableView.value = !isTableView.value;
  }

  void changeSymbol(String symbol) {
    if (selectedSymbol.value == symbol) return;
    selectedSymbol.value = symbol;
    fetchOrders();
  }

  void changeSide(String side) {
    if (selectedSide.value == side) return;
    selectedSide.value = side;
    fetchOrders();
  }

  List<Order> get filteredItems {
    final q = searchQuery.value.trim().toUpperCase();
    var list = items.toList();

    if (selectedSide.value == 'BUY') {
      list = list.where((o) => o.side == 1 || o.side.toString().toUpperCase() == 'BUY').toList();
    } else if (selectedSide.value == 'SELL') {
      list = list.where((o) => o.side == 2 || o.side.toString().toUpperCase() == 'SELL').toList();
    }

    if (q.isNotEmpty) {
      list = list.where((o) => o.symbol.toUpperCase().contains(q)).toList();
    }

    list.sort((a, b) => b.updateTime.compareTo(a.updateTime));
    return list;
  }

  Future<void> fetchOrders({bool isRefresh = false}) async {
    try {
      if (!isRefresh) isLoading(true);
      final symbolQuery = selectedSymbol.value == 'ALL' ? '' : selectedSymbol.value;

      final response = await OrdersApi.listings(
        symbol: symbolQuery,
        positionSide: '',
        status: '',
        current: 1,
        pageSize: 50,
      );
      items.value = response.data ?? [];
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar('获取订单数据失败', e.toString());
      }
    } finally {
      isLoading(false);
    }
  }
}
