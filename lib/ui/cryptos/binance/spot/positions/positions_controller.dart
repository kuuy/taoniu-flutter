import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/positions_api.dart';
import 'package:taoniu/models/cryptos/binance/spot/position.dart';

class PositionsController extends GetxController {
  final items = <Position>[].obs;
  final isLoading = true.obs;
  final isTableView = true.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPositions();
  }

  List<Position> get filteredItems {
    final q = searchQuery.value.trim().toUpperCase();
    final list = q.isEmpty
        ? List<Position>.from(items)
        : items.where((p) => p.symbol.toUpperCase().contains(q)).toList();
    list.sort((a, b) => b.entryAmount.compareTo(a.entryAmount));
    return list;
  }

  double get totalCapital => items.fold(0.0, (sum, item) => sum + item.capital);

  double get totalNotional => items.fold(0.0, (sum, item) => sum + item.notional);

  int get longCount => items.where((item) => item.side == 1).length;

  int get shortCount => items.where((item) => item.side == 2).length;

  void toggleViewMode() {
    isTableView.value = !isTableView.value;
  }

  Future<void> fetchPositions({bool isRefresh = false}) async {
    try {
      if (!isRefresh) isLoading(true);
      final response = await PositionsApi.gets();
      final list = response.data ?? [];
      list.sort((a, b) => b.entryAmount.compareTo(a.entryAmount));
      items.value = list;
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar('获取持仓失败', e.toString());
      }
    } finally {
      isLoading(false);
    }
  }
}

