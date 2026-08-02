import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/position_calc.dart';
import 'package:taoniu/ui/cryptos/binance/spot/positions/calc/positions_calc_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PositionCalcResult JSON Deserialization', () {
    test('parses PositionCalcResult correctly from JSON', () {
      final json = {
        'take_price': 65000.0,
        'stop_price': 58000.0,
        'tradings': [
          {
            'buy_price': 60000.0,
            'sell_price': 65000.0,
            'quantity': 0.005,
            'entry_price': 60000.0,
            'entry_quantity': 0.005,
          },
          {
            'buy_price': 58000.0,
            'sell_price': 65000.0,
            'quantity': 0.01,
            'entry_price': 58666.67,
            'entry_quantity': 0.015,
          }
        ]
      };

      final result = PositionCalcResult.fromJson(json);
      expect(result.takePrice, equals(65000.0));
      expect(result.stopPrice, equals(58000.0));
      expect(result.tradings.length, equals(2));
      expect(result.tradings[0].buyPrice, equals(60000.0));
      expect(result.tradings[1].quantity, equals(0.01));
    });
  });

  group('PositionsCalcController Logic Unit Tests', () {
    late PositionsCalcController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(PositionsCalcController());
    });

    test('initial values and preset symbols', () {
      expect(controller.symbolController.text, equals('BTCUSDT'));
      expect(controller.presetSymbols, contains('BTCUSDT'));
      expect(controller.presetSymbols, contains('ETHUSDT'));
      expect(controller.presetSymbols, contains('SOLUSDT'));
    });

    test('selectSymbol updates currentSymbol and text', () {
      controller.selectSymbol('ETHUSDT');
      expect(controller.symbolController.text, equals('ETHUSDT'));
      expect(controller.currentSymbol.value, equals('ETHUSDT'));
    });

    test('resetFields restores defaults', () {
      controller.symbolController.text = 'SOLUSDT';
      controller.maxCapitalController.text = '1000';
      controller.resetFields();

      expect(controller.symbolController.text, equals('BTCUSDT'));
      expect(controller.maxCapitalController.text, equals('400000000'));
      expect(controller.currentSymbol.value, equals('BTCUSDT'));
    });

    test('percentage and risk-reward ratio getters', () {
      controller.entryPriceController.text = '60000';
      controller.result.value = PositionCalcResult(
        takePrice: 66000.0,
        stopPrice: 57000.0,
        tradings: [],
      );

      // +10% take profit
      expect(controller.takeProfitChangePercent, closeTo(10.0, 0.01));
      // -5% stop loss
      expect(controller.stopLossChangePercent, closeTo(-5.0, 0.01));
      // R:R = (66000-60000) / (60000-57000) = 6000 / 3000 = 2.0
      expect(controller.riskRewardRatio, closeTo(2.0, 0.01));
    });
  });
}
