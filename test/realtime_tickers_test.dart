import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:taoniu/models/cryptos/binance/spot/spot_ticker.dart';

void main() {
  group('SpotTicker Model Tests', () {
    test('should correctly parse ticker JSON with signals and scientific price', () {
      final jsonMap = {
        "symbol": "EPXBUSD",
        "price": "3.24E-4",
        "change": 2.0,
        "signals": ["BUY"]
      };

      final ticker = SpotTicker.fromJson(jsonMap);

      expect(ticker.symbol, equals("EPXBUSD"));
      expect(ticker.price.value, closeTo(0.000324, 0.000001));
      expect(ticker.change24h.value, equals(2.0)); // 0.02 ratio -> 2.0%
      expect(ticker.signals.length, equals(1));
      expect(ticker.signals.first, equals("BUY"));
    });

    test('should update ticker price and detect direction up/down', () {
      final ticker = SpotTicker(symbol: "BTCUSDT", price: 100.0);

      expect(ticker.priceDirection.value, equals(0));

      ticker.updateFromJson({"price": 105.0});
      expect(ticker.price.value, equals(105.0));
      expect(ticker.priceDirection.value, equals(1));

      ticker.updateFromJson({"price": 95.0});
      expect(ticker.price.value, equals(95.0));
      expect(ticker.priceDirection.value, equals(-1));
    });

    test('should correctly sort tickers in descending order by 24h change', () {
      final list = [
        SpotTicker(symbol: "BTCUSDT", change24h: 1.25),
        SpotTicker(symbol: "ETHUSDT", change24h: 5.80),
        SpotTicker(symbol: "SOLUSDT", change24h: -0.32),
        SpotTicker(symbol: "DEXEUSDT", change24h: 12.45),
      ];

      list.sort((a, b) => b.change24h.value.compareTo(a.change24h.value));

      expect(list[0].symbol, equals("DEXEUSDT")); // 12.45%
      expect(list[1].symbol, equals("ETHUSDT"));  // 5.80%
      expect(list[2].symbol, equals("BTCUSDT"));  // 1.25%
      expect(list[3].symbol, equals("SOLUSDT"));  // -0.32%
    });

    test('should correctly construct WebSocket subscription payload', () {
      final symbols = ["BTCUSDT", "BNBUSDT", "ETHUSDT", "SOLUSDT", "DEXEUSDT"];
      final subPayload = {
        "action": "subscribe",
        "topic": "binance:spot:tickers",
        "symbols": symbols,
      };

      final jsonStr = jsonEncode(subPayload);
      final decoded = jsonDecode(jsonStr);

      expect(decoded["action"], equals("subscribe"));
      expect(decoded["topic"], equals("binance:spot:tickers"));
      expect(decoded["symbols"], contains("BTCUSDT"));
      expect(decoded["symbols"].length, equals(5));
    });
  });
}
