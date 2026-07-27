import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class MarketTicker {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final double price;
  final double change24h;
  final String volume24h;
  RxBool isFavorite;

  MarketTicker({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.price,
    required this.change24h,
    required this.volume24h,
    bool isFavorite = false,
  }) : isFavorite = isFavorite.obs;
}

class MarketsController extends GetxController {
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;

  final categories = ['All', 'Favorites', 'Spot', 'Top Gainers'];

  final tickers = <MarketTicker>[
    MarketTicker(symbol: 'BTCUSDT', baseAsset: 'BTC', quoteAsset: 'USDT', price: 64250.80, change24h: 3.42, volume24h: '1.24B', isFavorite: true),
    MarketTicker(symbol: 'ETHUSDT', baseAsset: 'ETH', quoteAsset: 'USDT', price: 3480.25, change24h: 4.15, volume24h: '850M', isFavorite: true),
    MarketTicker(symbol: 'BNBUSDT', baseAsset: 'BNB', quoteAsset: 'USDT', price: 585.60, change24h: -1.20, volume24h: '320M'),
    MarketTicker(symbol: 'SOLUSDT', baseAsset: 'SOL', quoteAsset: 'USDT', price: 145.30, change24h: 8.75, volume24h: '610M', isFavorite: true),
    MarketTicker(symbol: 'DOGEUSDT', baseAsset: 'DOGE', quoteAsset: 'USDT', price: 0.1245, change24h: 5.60, volume24h: '210M'),
    MarketTicker(symbol: 'XRPUSDT', baseAsset: 'XRP', quoteAsset: 'USDT', price: 0.5820, change24h: -0.85, volume24h: '180M'),
    MarketTicker(symbol: 'ADAUSDT', baseAsset: 'ADA', quoteAsset: 'USDT', price: 0.3950, change24h: 1.10, volume24h: '95M'),
    MarketTicker(symbol: 'AVAXUSDT', baseAsset: 'AVAX', quoteAsset: 'USDT', price: 27.80, change24h: 6.30, volume24h: '140M'),
  ].obs;

  List<MarketTicker> get filteredTickers {
    final query = searchQuery.value.toLowerCase().trim();
    final cat = selectedCategory.value;

    return tickers.where((t) {
      final matchesSearch = query.isEmpty ||
          t.symbol.toLowerCase().contains(query) ||
          t.baseAsset.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      if (cat == 'Favorites') return t.isFavorite.value;
      if (cat == 'Top Gainers') return t.change24h > 2.0;
      return true;
    }).toList();
  }

  void toggleFavorite(MarketTicker ticker) {
    ticker.isFavorite.value = !ticker.isFavorite.value;
  }

  void openTradingChart(MarketTicker ticker) {
    Get.toNamed(AppRoutes.binanceSpotTradings);
  }
}
