import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/position.dart';
import 'package:taoniu/ui/cryptos/binance/spot/positions/positions_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PositionsController Unit Tests', () {
    late PositionsController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(PositionsController());
    });

    test('Position.fromJson parsing', () {
      final json = {
        'id': 'pos_123',
        'symbol': 'BTCUSDT',
        'side': 1,
        'leverage': 10.0,
        'capital': 500.0,
        'notional': 5000.0,
        'entry_price': 60000.0,
        'entry_quantity': 0.0833,
        'entry_amount': 5000.0,
        'timestamp': 1700000000,
      };

      final pos = Position.fromJson(json);
      expect(pos.id, equals('pos_123'));
      expect(pos.symbol, equals('BTCUSDT'));
      expect(pos.side, equals(1));
      expect(pos.leverage, equals(10.0));
      expect(pos.capital, equals(500.0));
      expect(pos.entryAmount, equals(5000.0));
    });

    test('positions sorting by entryAmount descending', () {
      controller.items.value = [
        Position(
          id: '1',
          symbol: 'ETHUSDT',
          side: 1,
          leverage: 5.0,
          capital: 200.0,
          notional: 1000.0,
          entryPrice: 3000.0,
          entryQuantity: 0.33,
          entryAmount: 1000.0,
          timestamp: 0,
        ),
        Position(
          id: '2',
          symbol: 'BTCUSDT',
          side: 1,
          leverage: 10.0,
          capital: 1000.0,
          notional: 10000.0,
          entryPrice: 60000.0,
          entryQuantity: 0.166,
          entryAmount: 10000.0,
          timestamp: 0,
        ),
        Position(
          id: '3',
          symbol: 'SOLUSDT',
          side: 2,
          leverage: 5.0,
          capital: 500.0,
          notional: 2500.0,
          entryPrice: 150.0,
          entryQuantity: 16.6,
          entryAmount: 2500.0,
          timestamp: 0,
        ),
      ];

      final filtered = controller.filteredItems;
      // Should be sorted by entryAmount descending: BTCUSDT (10000) > SOLUSDT (2500) > ETHUSDT (1000)
      expect(filtered[0].symbol, equals('BTCUSDT'));
      expect(filtered[1].symbol, equals('SOLUSDT'));
      expect(filtered[2].symbol, equals('ETHUSDT'));
    });

    test('totals and counts computation', () {
      controller.items.value = [
        Position(
          id: '1',
          symbol: 'BTCUSDT',
          side: 1,
          leverage: 10,
          capital: 1000,
          notional: 10000,
          entryPrice: 60000,
          entryQuantity: 0.166,
          entryAmount: 10000,
          timestamp: 0,
        ),
        Position(
          id: '2',
          symbol: 'ETHUSDT',
          side: 2,
          leverage: 5,
          capital: 400,
          notional: 2000,
          entryPrice: 3000,
          entryQuantity: 0.66,
          entryAmount: 2000,
          timestamp: 0,
        ),
      ];

      expect(controller.totalCapital, equals(1400.0));
      expect(controller.totalNotional, equals(12000.0));
      expect(controller.longCount, equals(1));
      expect(controller.shortCount, equals(1));
    });

    test('searchQuery filtering', () {
      controller.items.value = [
        Position(
          id: '1',
          symbol: 'BTCUSDT',
          side: 1,
          leverage: 10,
          capital: 1000,
          notional: 10000,
          entryPrice: 60000,
          entryQuantity: 0.166,
          entryAmount: 10000,
          timestamp: 0,
        ),
        Position(
          id: '2',
          symbol: 'ETHUSDT',
          side: 1,
          leverage: 5,
          capital: 400,
          notional: 2000,
          entryPrice: 3000,
          entryQuantity: 0.66,
          entryAmount: 2000,
          timestamp: 0,
        ),
      ];

      controller.searchQuery.value = 'eth';
      final filtered = controller.filteredItems;
      expect(filtered.length, equals(1));
      expect(filtered.first.symbol, equals('ETHUSDT'));
    });
  });
}
