class Strategy {
  final String id;
  final String symbol;
  final String indicator;
  final int signal;
  final double price;
  final int timestamp;

  Strategy({
    required this.id,
    required this.symbol,
    required this.indicator,
    required this.signal,
    required this.price,
    required this.timestamp,
  });

  factory Strategy.fromJson(Map<String, dynamic> json) {
    return Strategy(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      indicator: json['indicator']?.toString() ?? '',
      signal: int.tryParse(json['signal']?.toString() ?? '') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      timestamp: int.tryParse(json['timestamp']?.toString() ?? '') ?? 0,
    );
  }
}
