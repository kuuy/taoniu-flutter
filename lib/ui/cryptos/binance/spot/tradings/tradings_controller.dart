import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taoniu/api/cryptos/binance/spot/indicators_api.dart';
import 'package:taoniu/api/cryptos/binance/spot/strategies_api.dart';
import 'package:taoniu/api/cryptos/binance/spot/klines_api.dart';
import 'package:taoniu/http/api_service.dart';
import 'package:taoniu/models/binance/spot/strategy.dart';
import 'package:taoniu/models/binance/spot/kline.dart';

class TradingsController extends GetxController {
  static const String _keySymbol = 'TRADINGVIEW_SELECTED_SYMBOL';
  static const String _keyInterval = 'TRADINGVIEW_SELECTED_INTERVAL';

  String get datafeedUrl => '${ApiService.baseUrl}/api/cryptos/v1/binance/spot/tradingview/datafeed';

  final selectedSymbol = 'BTCUSDT'.obs;
  final selectedInterval = '15m'.obs;
  final useTradingViewWidget = false.obs;

  void toggleChartMode() {
    useTradingViewWidget.value = !useTradingViewWidget.value;
  }

  final isLoadingIndicators = false.obs;
  final isLoadingSignals = false.obs;
  final isLoadingTradings = false.obs;
  final isLoadingKlines = false.obs;

  final indicators = <String, double>{}.obs;
  final strategySignals = <Strategy>[].obs;
  final klines = <Kline>[].obs;
  final tradingsList = <Map<String, dynamic>>[].obs;
  final selectedTrading = Rxn<Map<String, dynamic>>();

  final searchQuery = ''.obs;
  final statusFilter = ''.obs;
  final page = 0.obs;
  final rowsPerPage = 5.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _restoreSavedSymbolAndInterval();
    _startPeriodicRefresh();
  }

  Future<void> _restoreSavedSymbolAndInterval() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSymbol = prefs.getString(_keySymbol);
      final savedInterval = prefs.getString(_keyInterval);

      if (savedSymbol != null && savedSymbol.isNotEmpty) {
        selectedSymbol.value = savedSymbol;
      }
      if (savedInterval != null && savedInterval.isNotEmpty) {
        selectedInterval.value = KlinesApi.normalizeInterval(savedInterval);
      }
    } catch (_) {}
    await loadAllData();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchKlines(isSilent: true);
    });
  }

  Future<void> loadAllData() async {
    await Future.wait([
      fetchKlines(),
      fetchIndicators(),
      fetchSignals(),
      fetchTradings(),
    ]);
  }

  bool _isLoadingMoreKlines = false;

  Future<void> fetchKlines({bool isSilent = false}) async {
    try {
      if (!isSilent) isLoadingKlines.value = true;
      final response = await KlinesApi.fetch(
        symbol: selectedSymbol.value,
        interval: selectedInterval.value,
        limit: 100,
      );

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        if (klines.isEmpty || !isSilent) {
          klines.assignAll(response.data!);
        } else {
          final Map<int, Kline> map = {};
          for (final k in klines) {
            map[k.openTime] = k;
          }
          for (final k in response.data!) {
            map[k.openTime] = k;
          }
          final sorted = map.values.toList()..sort((a, b) => a.openTime.compareTo(b.openTime));
          klines.assignAll(sorted);
        }
      }
    } catch (e) {
      if (!isSilent) klines.clear();
    } finally {
      if (!isSilent) isLoadingKlines.value = false;
    }
  }

  Future<void> loadMoreKlines(int? oldestTimeSec) async {
    if (_isLoadingMoreKlines) return;
    try {
      _isLoadingMoreKlines = true;
      int? endTimeMs;
      if (oldestTimeSec != null && oldestTimeSec > 0) {
        endTimeMs = oldestTimeSec > 10000000000 ? oldestTimeSec - 1 : oldestTimeSec * 1000 - 1;
      } else if (klines.isNotEmpty) {
        final firstTime = klines.first.openTime;
        endTimeMs = firstTime > 10000000000 ? firstTime - 1 : firstTime * 1000 - 1;
      }

      final response = await KlinesApi.fetch(
        symbol: selectedSymbol.value,
        interval: selectedInterval.value,
        limit: 100,
        endTime: endTimeMs,
      );

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        final Map<int, Kline> map = {};
        for (final k in response.data!) {
          map[k.openTime] = k;
        }
        for (final k in klines) {
          map[k.openTime] = k;
        }
        final sorted = map.values.toList()..sort((a, b) => a.openTime.compareTo(b.openTime));
        klines.assignAll(sorted);
      }
    } catch (_) {
    } finally {
      _isLoadingMoreKlines = false;
    }
  }

  Future<void> fetchIndicators() async {
    try {
      isLoadingIndicators.value = true;
      final fields = [
        'r3',
        'r2',
        'r1',
        's1',
        's2',
        's3',
        'poc',
        'vah',
        'val',
        'profit_target',
        'take_profit_price',
        'stop_loss_point',
      ];
      final response = await IndicatorsApi.gets(
        symbols: selectedSymbol.value,
        interval: KlinesApi.normalizeInterval(selectedInterval.value),
        fields: fields.join(','),
      );

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        final rawData = response.data![0].split(',');
        final map = <String, double>{};
        for (int i = 0; i < fields.length && i < rawData.length; i++) {
          map[fields[i]] = double.tryParse(rawData[i]) ?? 0.0;
        }
        indicators.value = map;
      } else {
        indicators.clear();
      }
    } catch (e) {
      indicators.clear();
    } finally {
      isLoadingIndicators.value = false;
    }
  }

  Future<void> fetchSignals() async {
    try {
      isLoadingSignals.value = true;
      final response = await StrategiesApi.signals(
        symbol: selectedSymbol.value,
        interval: KlinesApi.normalizeInterval(selectedInterval.value),
      );

      if (response.success && response.data != null) {
        strategySignals.value = response.data!;
      } else {
        strategySignals.clear();
      }
    } catch (e) {
      strategySignals.clear();
    } finally {
      isLoadingSignals.value = false;
    }
  }

  Future<void> fetchTradings() async {
    try {
      isLoadingTradings.value = true;
      tradingsList.value = [
        {
          'id': 'TRD-1001',
          'symbol': selectedSymbol.value,
          'type': 'Scalping',
          'side': 'BUY',
          'price': 65430.50,
          'quantity': 0.05,
          'status': 'complete',
          'createdAt': DateTime.now().millisecondsSinceEpoch - 3600000,
        },
        {
          'id': 'TRD-1002',
          'symbol': selectedSymbol.value,
          'type': 'Trigger',
          'side': 'SELL',
          'price': 66800.00,
          'quantity': 0.05,
          'status': 'pending',
          'createdAt': DateTime.now().millisecondsSinceEpoch - 1800000,
        },
      ];
    } catch (e) {
      tradingsList.clear();
    } finally {
      isLoadingTradings.value = false;
    }
  }

  void changeSymbol(String symbol) {
    if (selectedSymbol.value != symbol) {
      selectedSymbol.value = symbol;
      _saveSelectedSymbol(symbol);
      klines.clear();
      indicators.clear();
      strategySignals.clear();
      loadAllData();
      _startPeriodicRefresh();
    }
  }

  void changeInterval(String interval) {
    final normalized = KlinesApi.normalizeInterval(interval);
    if (selectedInterval.value != normalized) {
      selectedInterval.value = normalized;
      _saveSelectedInterval(normalized);
      klines.clear();
      indicators.clear();
      strategySignals.clear();
      fetchKlines();
      fetchIndicators();
      fetchSignals();
      _startPeriodicRefresh();
    }
  }

  Future<void> _saveSelectedSymbol(String symbol) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySymbol, symbol);
    } catch (_) {}
  }

  Future<void> _saveSelectedInterval(String interval) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyInterval, interval);
    } catch (_) {}
  }

  void selectTrading(Map<String, dynamic> item) {
    if (selectedTrading.value?['id'] == item['id']) {
      selectedTrading.value = null;
    } else {
      selectedTrading.value = item;
    }
  }

  void closeTradingDrawer() {
    selectedTrading.value = null;
  }
}
