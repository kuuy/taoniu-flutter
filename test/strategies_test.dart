import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/strategy.dart';
import 'package:taoniu/ui/cryptos/binance/spot/strategies/strategies_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Strategy Model Parsing', () {
    test('parses Strategy correctly from JSON', () {
      final json = {
        'id': 'strat_001',
        'symbol': 'BTCUSDT',
        'indicator': 'MA_CROSS',
        'signal': 1,
        'price': 65000.0,
        'timestamp': 1700000000,
      };

      final strategy = Strategy.fromJson(json);
      expect(strategy.id, equals('strat_001'));
      expect(strategy.symbol, equals('BTCUSDT'));
      expect(strategy.indicator, equals('MA_CROSS'));
      expect(strategy.signal, equals(1));
      expect(strategy.isBuy, isTrue);
      expect(strategy.signalLabel, equals('BUY'));
      expect(strategy.price, equals(65000.0));
    });

    test('parses string signal correctly', () {
      final json = {
        'id': 'strat_002',
        'symbol': 'ETHUSDT',
        'indicator': 'RSI_OVERBOUGHT',
        'signal': 'SELL',
        'price': 3500.0,
        'timestamp': 1700000000,
      };

      final strategy = Strategy.fromJson(json);
      expect(strategy.isSell, isTrue);
      expect(strategy.signalLabel, equals('SELL'));
    });
  });

  group('StrategiesController Logic Unit Tests', () {
    late StrategiesController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(StrategiesController());
    });

    test('initial interval and signal filters', () {
      expect(controller.selectedInterval.value, equals('1m'));
      expect(controller.selectedSignal.value, equals('ALL'));
      expect(controller.signals, containsAll(['ALL', 'BUY', 'SELL']));
    });

    test('getFilteredData applies signal and searchQuery filter', () {
      controller.strategiesData['1m'] = [
        Strategy(
          id: '1',
          symbol: 'BTCUSDT',
          indicator: 'MACD',
          signal: 1,
          price: 60000.0,
          timestamp: 100,
        ),
        Strategy(
          id: '2',
          symbol: 'SOLUSDT',
          indicator: 'KDJ',
          signal: -1,
          price: 140.0,
          timestamp: 200,
        ),
      ];

      controller.changeSignal('BUY');
      var filtered = controller.getFilteredData('1m');
      expect(filtered.length, equals(1));
      expect(filtered.first.symbol, equals('BTCUSDT'));

      controller.changeSignal('ALL');
      controller.searchQuery.value = 'sol';
      filtered = controller.getFilteredData('1m');
      expect(filtered.length, equals(1));
      expect(filtered.first.symbol, equals('SOLUSDT'));
    });
  });
}
