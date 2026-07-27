class Scalping {
  final String id;
  final String symbol;
  final int side;
  final double capital;
  final double price;
  final double takePrice;
  final double stopPrice;
  final int timestamp;
  final int status;

  Scalping({
    required this.id,
    required this.symbol,
    required this.side,
    required this.capital,
    required this.price,
    required this.takePrice,
    required this.stopPrice,
    required this.timestamp,
    required this.status,
  });

  factory Scalping.fromJson(Map<String, dynamic> json) {
    return Scalping(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      side: int.tryParse(json['side']?.toString() ?? '') ?? 0,
      capital: double.tryParse(json['capital']?.toString() ?? '') ?? 0.0,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      takePrice: double.tryParse(json['take_price']?.toString() ?? '') ?? 0.0,
      stopPrice: double.tryParse(json['stop_price']?.toString() ?? '') ?? 0.0,
      timestamp: int.tryParse(json['timestamp']?.toString() ?? '') ?? 0,
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
    );
  }
}
