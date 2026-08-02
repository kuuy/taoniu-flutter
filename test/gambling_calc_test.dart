import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/gambling_calc.dart';
import 'package:taoniu/ui/cryptos/binance/spot/gambling/calc/gambling_calc_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GamblingCalcResult JSON Deserialization', () {
    test('parses GamblingCalcResult correctly from JSON', () {
      final json = {
        'take_price': 70000.0,
        'stop_price': 55000.0,
        'plan_profit': 1500.5,
        'plans': [
          {
            'price': 62000.0,
            'quantity': 0.01,
            'take_profit': 100.0,
            'amount': 620.0,
            'profit': 100.0,
          },
          {
            'price': 65000.0,
            'quantity': 0.01,
            'take_profit': 150.0,
            'amount': 650.0,
            'profit': 250.0,
          }
        ]
      };

      final result = GamblingCalcResult.fromJson(json);
      expect(result.takePrice, equals(70000.0));
      expect(result.stopPrice, equals(55000.0));
      expect(result.planProfit, equals(1500.5));
      expect(result.plans.length, equals(2));
      expect(result.plans[0].takeProfit, equals(100.0));
      expect(result.plans[1].profit, equals(250.0));
    });
  });

  group('GamblingCalcController Logic Unit Tests', () {
    late GamblingCalcController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(GamblingCalcController());
    });

    test('initial values and side selection', () {
      expect(controller.symbolController.text, equals('BTCUSDT'));
      expect(controller.selectedSide.value, equals(1));

      controller.selectedSide.value = 2; // SELL
      expect(controller.selectedSide.value, equals(2));
    });

    test('selectSymbol updates currentSymbol and symbolController text', () {
      controller.selectSymbol('SOLUSDT');
      expect(controller.symbolController.text, equals('SOLUSDT'));
      expect(controller.currentSymbol.value, equals('SOLUSDT'));
    });

    test('resetFields clears entry fields and restores side to 1', () {
      controller.entryPriceController.text = '60000';
      controller.entryQuantityController.text = '0.05';
      controller.selectedSide.value = 2;

      controller.resetFields();

      expect(controller.symbolController.text, equals('BTCUSDT'));
      expect(controller.selectedSide.value, equals(1));
      expect(controller.entryPriceController.text, isEmpty);
      expect(controller.entryQuantityController.text, isEmpty);
    });

    test('take profit and stop loss percentage change calculations', () {
      controller.entryPriceController.text = '60000';
      controller.result.value = GamblingCalcResult(
        takePrice: 69000.0,
        stopPrice: 54000.0,
        planProfit: 2000.0,
        plans: [],
      );

      // +15% take profit
      expect(controller.takeProfitChangePercent, closeTo(15.0, 0.01));
      // -10% stop loss
      expect(controller.stopLossChangePercent, closeTo(-10.0, 0.01));
    });
  });
}
