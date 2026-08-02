import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/plan.dart';
import 'package:taoniu/ui/cryptos/binance/spot/plans/plans_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Plan Model Parsing', () {
    test('parses Plan correctly from JSON', () {
      final json = {
        'id': 'plan_001',
        'symbol': 'BTCUSDT',
        'side': 1,
        'price': 62000.0,
        'quantity': 0.05,
        'amount': 3100.0,
        'status': 1,
        'timestamp': 1700000000,
      };

      final plan = Plan.fromJson(json);
      expect(plan.id, equals('plan_001'));
      expect(plan.symbol, equals('BTCUSDT'));
      expect(plan.side, equals(1));
      expect(plan.price, equals(62000.0));
      expect(plan.amount, equals(3100.0));
    });
  });

  group('BinanceSpotPlansController Logic Unit Tests', () {
    late BinanceSpotPlansController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(BinanceSpotPlansController());
    });

    test('initial interval and intervals list', () {
      expect(controller.selectedInterval.value, equals('1m'));
      expect(controller.intervals, containsAll(['1m', '15m', '4h', '1d']));
    });

    test('getFilteredData applies searchQuery filter', () {
      controller.plansData['1m'] = [
        Plan(
          id: '1',
          symbol: 'BTCUSDT',
          side: 1,
          price: 60000.0,
          quantity: 0.1,
          amount: 6000.0,
          status: 1,
          timestamp: 100,
        ),
        Plan(
          id: '2',
          symbol: 'SOLUSDT',
          side: 2,
          price: 150.0,
          quantity: 10.0,
          amount: 1500.0,
          status: 1,
          timestamp: 200,
        ),
      ];

      controller.searchQuery.value = 'sol';
      final filtered = controller.getFilteredData('1m');
      expect(filtered.length, equals(1));
      expect(filtered.first.symbol, equals('SOLUSDT'));
    });
  });
}
