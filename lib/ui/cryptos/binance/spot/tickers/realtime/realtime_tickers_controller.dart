  import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taoniu/api/cryptos/binance/spot/tickers/ranking_api.dart';
import 'package:taoniu/models/cryptos/binance/spot/spot_ticker.dart';
import 'package:taoniu/services/binance_spot_ws_service.dart';

enum TickerSortField {
  change24h,
  price,
  volume,
  symbol,
}

class RealtimeTickersController extends GetxController {
  final BinanceSpotWsService wsService = BinanceSpotWsService();
  static const String _keyCachedSymbols = 'REALTIME_TICKERS_CACHED_SYMBOLS';

  final tickers = <String, SpotTicker>{}.obs;
  final activeSymbols = <String>[].obs;

  final searchQuery = ''.obs;
  final wsStatus = WsConnectionStatus.disconnected.obs;
  final isLoadingRanking = false.obs;

  final sortField = TickerSortField.change24h.obs;
  final sortAscending = false.obs;

  final presetSymbols = const ['BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT', 'DOGEUSDT', 'XRPUSDT', 'PEPEUSDT'];

  StreamSubscription? _statusSub;
  StreamSubscription? _messageSub;

  SpotTicker _getOrCreateTicker(String sym) {
    final cleanSym = sym.trim().toUpperCase();
    if (!tickers.containsKey(cleanSym)) {
      tickers[cleanSym] = SpotTicker(symbol: cleanSym);
    }
    return tickers[cleanSym]!;
  }

  List<SpotTicker> get filteredTickers {
    final query = searchQuery.value.trim().toUpperCase();
    final list = activeSymbols.map((sym) => _getOrCreateTicker(sym)).toList();

    list.sort((a, b) {
      int cmp = 0;
      switch (sortField.value) {
        case TickerSortField.change24h:
          cmp = a.change24h.value.compareTo(b.change24h.value);
          break;
        case TickerSortField.price:
          cmp = a.price.value.compareTo(b.price.value);
          break;
        case TickerSortField.volume:
          cmp = a.volume.value.compareTo(b.volume.value);
          break;
        case TickerSortField.symbol:
          cmp = a.symbol.compareTo(b.symbol);
          break;
      }
      return sortAscending.value ? cmp : -cmp;
    });

    if (query.isEmpty) {
      return list;
    }
    return list.where((t) => t.symbol.toUpperCase().contains(query)).toList();
  }

  int get gainersCount => activeSymbols.where((sym) => _getOrCreateTicker(sym).change24h.value > 0).length;
  int get losersCount => activeSymbols.where((sym) => _getOrCreateTicker(sym).change24h.value < 0).length;

  void toggleSort(TickerSortField field) {
    if (sortField.value == field) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortField.value = field;
      sortAscending.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadCachedSymbols();
    fetchDefaultSymbolsFromRankingApi();
  }

  Future<void> _loadCachedSymbols() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getStringList(_keyCachedSymbols);
      if (cached != null && cached.isNotEmpty && activeSymbols.isEmpty) {
        activeSymbols.assignAll(cached);
      }
    } catch (e) {
      if (kDebugMode) {
        print('RealtimeTickersController load cached symbols error: $e');
      }
    }
  }

  Future<void> _saveCachedSymbols(List<String> symbols) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyCachedSymbols, symbols);
    } catch (e) {
      if (kDebugMode) {
        print('RealtimeTickersController save cached symbols error: $e');
      }
    }
  }

  Future<void> fetchDefaultSymbolsFromRankingApi() async {
    try {
      isLoadingRanking.value = true;
      final response = await TickersRankingApi.ranking(
        symbols: "",
        fields: "price,open,high,low,volume,quota,change",
        sort: "change,-1",
        current: 1,
        pageSize: 200,
      );

      final itemsList = response.data ?? [];
      if (itemsList.isNotEmpty) {
        final List<String> fetchedSymbols = [];
        for (var csvItem in itemsList) {
          final parts = csvItem.split(',');
          if (parts.isNotEmpty) {
            final sym = parts[0].trim().toUpperCase();
            if (sym.isNotEmpty) {
              fetchedSymbols.add(sym);

              double? p = parts.length > 1 ? double.tryParse(parts[1]) : null;
              double? h = parts.length > 3 ? double.tryParse(parts[3]) : null;
              double? l = parts.length > 4 ? double.tryParse(parts[4]) : null;
              double? v = parts.length > 5 ? double.tryParse(parts[5]) : null;
              double? c = parts.length > 7 ? double.tryParse(parts[7]) : (parts.length > 6 ? double.tryParse(parts[6]) : null);

              final normChange = SpotTicker.normalizeChangePercent(c ?? 0.0);

              final ticker = _getOrCreateTicker(sym);
              if (p != null && p > 0) ticker.price.value = p;
              ticker.change24h.value = normChange;
              if (h != null) ticker.high.value = h;
              if (l != null) ticker.low.value = l;
              if (v != null) ticker.volume.value = v;
            }
          }
        }

        if (fetchedSymbols.isNotEmpty) {
          activeSymbols.assignAll(fetchedSymbols);
          _saveCachedSymbols(fetchedSymbols);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('RealtimeTickersController fetch ranking error: $e');
      }
    } finally {
      isLoadingRanking.value = false;
      _listenWs();
      connectWs();
    }
  }

  void _listenWs() {
    _statusSub?.cancel();
    _messageSub?.cancel();

    _statusSub = wsService.statusStream.listen((status) {
      wsStatus.value = status;
    });

    _messageSub = wsService.messageStream.listen((data) {
      _handleWsMessage(data);
    });
  }

  void connectWs() {
    if (activeSymbols.isNotEmpty) {
      wsService.subscribe(activeSymbols.toList());
    }
  }

  void _handleWsMessage(Map<String, dynamic> data) {
    // Handle payload tick formats
    if (data.containsKey('symbol') || data.containsKey('s') || data.containsKey('sym') || data.containsKey('name')) {
      final sym = (data['symbol'] ?? data['s'] ?? data['sym'] ?? data['name']).toString().toUpperCase();
      if (sym.isNotEmpty) {
        final ticker = _getOrCreateTicker(sym);
        ticker.updateFromJson(data);
        tickers.refresh();
      }
    } else if (data['data'] != null) {
      final inner = data['data'];
      if (inner is List) {
        for (var item in inner) {
          if (item is Map<String, dynamic>) _handleWsMessage(item);
        }
      } else if (inner is Map<String, dynamic>) {
        _handleWsMessage(inner);
      }
    } else if (data['payload'] != null) {
      final inner = data['payload'];
      if (inner is List) {
        for (var item in inner) {
          if (item is Map<String, dynamic>) _handleWsMessage(item);
        }
      } else if (inner is Map<String, dynamic>) {
        _handleWsMessage(inner);
      }
    } else if (data['result'] != null) {
      final inner = data['result'];
      if (inner is List) {
        for (var item in inner) {
          if (item is Map<String, dynamic>) _handleWsMessage(item);
        }
      } else if (inner is Map<String, dynamic>) {
        _handleWsMessage(inner);
      }
    } else if (data['tickers'] != null && data['tickers'] is List) {
      for (var item in (data['tickers'] as List)) {
        if (item is Map<String, dynamic>) _handleWsMessage(item);
      }
    }
  }

  void addSymbol(String symbol) {
    final cleanSym = symbol.trim().toUpperCase();
    if (cleanSym.isEmpty || activeSymbols.contains(cleanSym)) return;

    activeSymbols.add(cleanSym);
    _getOrCreateTicker(cleanSym);
    _saveCachedSymbols(activeSymbols.toList());
    wsService.subscribe([cleanSym]);
  }

  void removeSymbol(String symbol) {
    final cleanSym = symbol.trim().toUpperCase();
    activeSymbols.remove(cleanSym);
    _saveCachedSymbols(activeSymbols.toList());
    wsService.unsubscribe([cleanSym]);
    tickers.remove(cleanSym);
  }

  void reconnect() {
    wsService.disconnect();
    fetchDefaultSymbolsFromRankingApi();
  }

  @override
  void onClose() {
    _statusSub?.cancel();
    _messageSub?.cancel();
    wsService.dispose();
    super.onClose();
  }
}
