import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/order.dart';
import 'package:taoniu/ui/cryptos/binance/spot/orders/orders_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Order Model Parsing', () {
    test('parses Order correctly from JSON', () {
      final json = {
        'id': 'ord_001',
        'symbol': 'BTCUSDT',
        'order_id': 10001,
        'type': 'LIMIT',
        'side': 1,
        'price': 64000.0,
        'quantity': 0.05,
        'open_time': 1700000000,
        'update_time': 1700001000,
        'reduce_only': false,
        'status': 'FILLED',
      };

      final order = Order.fromJson(json);
      expect(order.id, equals('ord_001'));
      expect(order.symbol, equals('BTCUSDT'));
      expect(order.orderId, equals(10001));
      expect(order.side, equals(1));
      expect(order.price, equals(64000.0));
      expect(order.quantity, equals(0.05));
      expect(order.status, equals('FILLED'));
    });
  });

  group('OrdersController Logic Unit Tests', () {
    late OrdersController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(OrdersController());
    });

    test('initial symbols and view mode toggle', () {
      expect(controller.selectedSymbol.value, equals('ALL'));
      expect(controller.selectedSide.value, equals('ALL'));
      expect(controller.isTableView.value, isTrue);

      controller.toggleViewMode();
      expect(controller.isTableView.value, isFalse);
    });

    test('filteredItems applies side and searchQuery filter', () {
      controller.items.value = [
        Order(
          id: '1',
          symbol: 'BTCUSDT',
          orderId: 1,
          type: 'LIMIT',
          side: 1,
          price: 60000.0,
          quantity: 0.1,
          openTime: 100,
          updateTime: 200,
          reduceOnly: false,
          status: 'NEW',
        ),
        Order(
          id: '2',
          symbol: 'ETHUSDT',
          orderId: 2,
          type: 'LIMIT',
          side: 2,
          price: 3000.0,
          quantity: 1.0,
          openTime: 150,
          updateTime: 250,
          reduceOnly: false,
          status: 'FILLED',
        ),
      ];

      controller.selectedSide.value = 'BUY';
      expect(controller.filteredItems.length, equals(1));
      expect(controller.filteredItems.first.symbol, equals('BTCUSDT'));

      controller.selectedSide.value = 'ALL';
      controller.searchQuery.value = 'eth';
      expect(controller.filteredItems.length, equals(1));
      expect(controller.filteredItems.first.symbol, equals('ETHUSDT'));
    });
  });
}
