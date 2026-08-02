import 'dart:async';
import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/tickers/ranking_api.dart';
import 'package:taoniu/services/binance_spot_ws_service.dart';

class TickersRankingController extends GetxController {
  final BinanceSpotWsService wsService = BinanceSpotWsService();
  StreamSubscription? _messageSub;

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
    _listenWs();
  }

  @override
  void onClose() {
    _messageSub?.cancel();
    wsService.dispose();
    super.onClose();
  }

  void _listenWs() {
    _messageSub?.cancel();
    _messageSub = wsService.messageStream.listen((data) {
      _handleWsMessage(data);
    });
  }

  void _handleWsMessage(Map<String, dynamic> data) {
    final sym = (data['symbol'] ?? data['s'] ?? data['sym'] ?? data['name'])?.toString().toUpperCase();
    if (sym == null || sym.isEmpty) return;

    final pStr = (data['price'] ?? data['p'] ?? data['close'] ?? data['c'])?.toString();
    final cStr = (data['change'] ?? data['P'] ?? data['percent'])?.toString();

    if (pStr == null && cStr == null) return;

    final list = items.toList();
    bool updated = false;
    for (int i = 0; i < list.length; i++) {
      final parts = list[i].split(',');
      if (parts.isNotEmpty && parts[0].trim().toUpperCase() == sym) {
        // parts[1] is price, parts[7] or parts[6] is change
        if (pStr != null && parts.length > 1) parts[1] = pStr;
        if (cStr != null && parts.length > 7) parts[7] = cStr;
        list[i] = parts.join(',');
        updated = true;
        break;
      }
    }
    if (updated) {
      items.assignAll(list);
    }
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
      final fetchedSymbols = items.map((item) => item.split(',').first.trim().toUpperCase()).where((s) => s.isNotEmpty).toList();
      if (fetchedSymbols.isNotEmpty) {
        wsService.subscribe(fetchedSymbols.take(50).toList());
      }
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar('获取行情排行榜失败', e.toString());
      }
    } finally {
      isLoading(false);
    }
  }
}
