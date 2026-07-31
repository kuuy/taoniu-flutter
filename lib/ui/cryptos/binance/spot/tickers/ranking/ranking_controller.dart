import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/tickers/ranking_api.dart';

class TickersRankingController extends GetxController {
  final items = <String>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  final sortFieldIndex = 6.obs; // Default to 'change' (index 6 in fields)
  final sortAscending = false.obs; // Default descending

  final fields = const [
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

  void toggleSort(int fieldIndex) {
    if (sortFieldIndex.value == fieldIndex) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortFieldIndex.value = fieldIndex;
      sortAscending.value = false;
    }
  }

  List<String> get filteredItems {
    final q = searchQuery.value.trim().toUpperCase();
    var list = items.toList();

    if (q.isNotEmpty) {
      list = list.where((item) {
        final symbol = item.split(',').first;
        return symbol.toUpperCase().contains(q);
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

  Future<void> fetchRanking({bool isRefresh = false}) async {
    try {
      if (!isRefresh) isLoading(true);
      final response = await TickersRankingApi.ranking(
        symbols: "",
        fields: fields.join(','),
        sort: "change,-1",
        current: 1,
        pageSize: 200,
      );
      items.value = response.data ?? [];
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar('获取行情排行榜失败', e.toString());
      }
    } finally {
      isLoading(false);
    }
  }
}
