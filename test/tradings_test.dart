import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/cryptos/binance/spot/tradings/tradings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TradingsController Logic Unit Tests', () {
    late TradingsController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(TradingsController());
    });

    test('initial state and chart mode toggle', () {
      expect(controller.selectedSymbol.value, equals('BTCUSDT'));
      expect(controller.selectedInterval.value, equals('15m'));
      expect(controller.useTradingViewWidget.value, isFalse);

      controller.toggleChartMode();
      expect(controller.useTradingViewWidget.value, isTrue);
    });

    test('selectTrading toggles selected trading drawer', () {
      final item = {
        'id': 'TRD-1001',
        'symbol': 'BTCUSDT',
        'price': 65000.0,
      };

      controller.selectTrading(item);
      expect(controller.selectedTrading.value?['id'], equals('TRD-1001'));

      controller.closeTradingDrawer();
      expect(controller.selectedTrading.value, isNull);
    });
  });
}
