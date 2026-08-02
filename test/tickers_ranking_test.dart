import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/cryptos/binance/spot/tickers/ranking/ranking_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TickersRankingController Logic Unit Tests', () {
    late TickersRankingController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(TickersRankingController());
    });

    test('initial fields and default sort index', () {
      expect(controller.sortFieldIndex.value, equals(6)); // 'change' index
      expect(controller.sortAscending.value, isFalse);
      expect(controller.fields, containsAll(['price', 'volume', 'change']));
    });

    test('toggleSort switches field and ascending flag', () {
      controller.toggleSort(0); // 'price' index
      expect(controller.sortFieldIndex.value, equals(0));
      expect(controller.sortAscending.value, isFalse);

      controller.toggleSort(0);
      expect(controller.sortAscending.value, isTrue);
    });

    test('filteredItems applies searchQuery and dynamic column sort', () {
      controller.items.value = [
        'BTCUSDT,60000.0,59000.0,61000.0,58000.0,100.0,500.0,2.5,0.1,0.2',
        'ETHUSDT,3000.0,2900.0,3100.0,2800.0,500.0,2000.0,-1.5,0.1,0.2',
        'SOLUSDT,150.0,140.0,160.0,135.0,200.0,800.0,8.0,0.1,0.2',
      ];

      // Sort by 'change' (index 6, which is column 7 after symbol) descending
      controller.sortFieldIndex.value = 6;
      controller.sortAscending.value = false;

      var list = controller.filteredItems;
      expect(list.first.split(',').first, equals('SOLUSDT')); // 8.0 % highest

      // Apply search query
      controller.searchQuery.value = 'eth';
      list = controller.filteredItems;
      expect(list.length, equals(1));
      expect(list.first.split(',').first, equals('ETHUSDT'));
    });
  });
}
