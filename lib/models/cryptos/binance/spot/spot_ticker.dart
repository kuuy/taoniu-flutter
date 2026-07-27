import 'package:get/get.dart';

class SpotTicker {
  final String symbol;
  RxDouble price;
  RxDouble change24h;
  RxDouble high;
  RxDouble low;
  RxDouble volume;
  RxList<String> signals;
  RxInt priceDirection; // 1: up, -1: down, 0: neutral
  DateTime lastUpdated;

  SpotTicker({
    required this.symbol,
    double price = 0.0,
    double change24h = 0.0,
    double high = 0.0,
    double low = 0.0,
    double volume = 0.0,
    List<String>? signals,
    int priceDirection = 0,
    DateTime? lastUpdated,
  })  : price = price.obs,
        change24h = change24h.obs,
        high = high.obs,
        low = low.obs,
        volume = volume.obs,
        signals = (signals ?? []).obs,
        priceDirection = priceDirection.obs,
        lastUpdated = lastUpdated ?? DateTime.now();

  factory SpotTicker.fromJson(Map<String, dynamic> json) {
    final sym = json['symbol'] ?? json['s'] ?? json['sym'] ?? json['name'] ?? '';
    final p = _parseDouble(_extractPrice(json));
    final rawChange = _parseDouble(_extractChange(json));
    final c = normalizeChangePercent(rawChange);
    final h = _parseDouble(json['high'] ?? json['h'] ?? json['highPrice'] ?? 0);
    final l = _parseDouble(json['low'] ?? json['l'] ?? json['lowPrice'] ?? 0);
    final v = _parseDouble(json['volume'] ?? json['v'] ?? json['vol'] ?? 0);
    
    List<String> sigList = [];
    if (json['signals'] is List) {
      sigList = (json['signals'] as List).map((e) => e.toString()).toList();
    } else if (json['signal'] != null) {
      sigList = [json['signal'].toString()];
    } else if (json['tags'] is List) {
      sigList = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    return SpotTicker(
      symbol: sym.toString().toUpperCase(),
      price: p,
      change24h: c,
      high: h,
      low: l,
      volume: v,
      signals: sigList,
    );
  }

  void updateFromJson(Map<String, dynamic> json) {
    final extractedPrice = _extractPrice(json);
    if (extractedPrice != null) {
      final newPrice = _parseDouble(extractedPrice);
      if (newPrice != 0.0 && newPrice != price.value) {
        if (newPrice > price.value) {
          priceDirection.value = 1;
        } else if (newPrice < price.value) {
          priceDirection.value = -1;
        }
        price.value = newPrice;
      }
    }

    final extractedChange = _extractChange(json);
    if (extractedChange != null) {
      final rawChange = _parseDouble(extractedChange);
      change24h.value = normalizeChangePercent(rawChange);
    } else {
      final openPrice = _parseDouble(json['open'] ?? json['o'] ?? json['open_price'] ?? json['openPrice'] ?? 0);
      if (openPrice > 0 && price.value > 0) {
        change24h.value = ((price.value - openPrice) / openPrice) * 100.0;
      }
    }

    if (json['high'] != null || json['h'] != null || json['highPrice'] != null) {
      high.value = _parseDouble(json['high'] ?? json['h'] ?? json['highPrice']);
    }
    if (json['low'] != null || json['l'] != null || json['lowPrice'] != null) {
      low.value = _parseDouble(json['low'] ?? json['l'] ?? json['lowPrice']);
    }
    if (json['volume'] != null || json['v'] != null || json['vol'] != null) {
      volume.value = _parseDouble(json['volume'] ?? json['v'] ?? json['vol']);
    }
    if (json['signals'] is List) {
      signals.assignAll((json['signals'] as List).map((e) => e.toString()).toList());
    } else if (json['signal'] != null) {
      signals.assignAll([json['signal'].toString()]);
    } else if (json['tags'] is List) {
      signals.assignAll((json['tags'] as List).map((e) => e.toString()).toList());
    }
    lastUpdated = DateTime.now();
  }

  static double normalizeChangePercent(double rawChange) {
    return double.parse(rawChange.toStringAsFixed(2));
  }

  static dynamic _extractPrice(Map<String, dynamic> json) {
    return json['price'] ??
        json['p'] ??
        json['last_price'] ??
        json['lastPrice'] ??
        json['close'] ??
        json['c'] ??
        json['last'] ??
        json['val'] ??
        json['rate'];
  }

  static dynamic _extractChange(Map<String, dynamic> json) {
    return json['change'] ??
        json['P'] ??
        json['price_change_percent'] ??
        json['priceChangePercent'] ??
        json['change24h'] ??
        json['ratio'] ??
        json['percent'];
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? 0.0;
    }
    return 0.0;
  }
}
