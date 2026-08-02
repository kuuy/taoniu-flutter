import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/scalping.dart';
import 'package:taoniu/ui/cryptos/binance/spot/scalping/scalping_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Scalping Model Parsing', () {
    test('parses Scalping item correctly from JSON', () {
      final json = {
        'id': 'scalp_001',
        'symbol': 'BTCUSDT',
        'side': 1,
        'capital': 1000.0,
        'price': 65000.0,
        'take_price': 68000.0,
        'stop_price': 63000.0,
        'status': 1,
        'timestamp': 1700000000,
      };

      final item = Scalping.fromJson(json);
      expect(item.id, equals('scalp_001'));
      expect(item.symbol, equals('BTCUSDT'));
      expect(item.isBuy, isTrue);
      expect(item.sideLabel, equals('BUY'));
      expect(item.capital, equals(1000.0));
      expect(item.price, equals(65000.0));
      expect(item.takePrice, equals(68000.0));
      expect(item.stopPrice, equals(63000.0));
    });
  });

  group('ScalpingController Logic Unit Tests', () {
    late ScalpingController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(ScalpingController());
    });

    test('initial symbol and side filters', () {
      expect(controller.selectedSymbol.value, equals('ALL'));
      expect(controller.selectedSide.value, equals('ALL'));
      expect(controller.symbols, contains('BTCUSDT'));
      expect(controller.sides, containsAll(['ALL', 'BUY', 'SELL']));
    });

    test('changeSymbol updates selectedSymbol filter', () {
      controller.changeSymbol('SOLUSDT');
      expect(controller.selectedSymbol.value, equals('SOLUSDT'));
    });

    test('changeSide updates selectedSide filter', () {
      controller.changeSide('BUY');
      expect(controller.selectedSide.value, equals('BUY'));
    });
  });
}
