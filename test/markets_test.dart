import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/markets/markets_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MarketsController Logic Unit Tests', () {
    late MarketsController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(MarketsController());
    });

    test('initial state and categories', () {
      expect(controller.selectedCategory.value, equals('All'));
      expect(controller.categories, containsAll(['All', 'Favorites', 'Spot', 'Top Gainers']));
      expect(controller.tickers.length, greaterThan(0));
    });

    test('toggleFavorite toggles ticker favorite state', () {
      final ticker = controller.tickers.first;
      final initialFav = ticker.isFavorite.value;

      controller.toggleFavorite(ticker);
      expect(ticker.isFavorite.value, equals(!initialFav));
    });

    test('filteredTickers applies search and category filter', () {
      controller.searchQuery.value = 'btc';
      var list = controller.filteredTickers;
      expect(list.length, equals(1));
      expect(list.first.symbol, equals('BTCUSDT'));

      controller.searchQuery.value = '';
      controller.selectedCategory.value = 'Favorites';
      list = controller.filteredTickers;
      expect(list.every((t) => t.isFavorite.value), isTrue);
    });
  });
}
