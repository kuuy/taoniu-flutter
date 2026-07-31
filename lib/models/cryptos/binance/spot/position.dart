class Position {
  final String id;
  final String symbol;
  final int side;
  final double leverage;
  final double capital;
  final double notional;
  final double entryPrice;
  final double entryQuantity;
  final double entryAmount;
  final int timestamp;

  Position({
    required this.id,
    required this.symbol,
    required this.side,
    required this.leverage,
    required this.capital,
    required this.notional,
    required this.entryPrice,
    required this.entryQuantity,
    required this.entryAmount,
    required this.timestamp,
  });

  bool get isBuy => side == 1;

  factory Position.fromJson(Map<String, dynamic> json) {
    final rawSide = json['side']?.toString() ?? '';
    int sideVal = int.tryParse(rawSide) ?? 0;
    if (sideVal == 0) {
      final u = rawSide.trim().toUpperCase();
      if (u == 'BUY' || u == 'BUY_LIMIT' || u == 'LONG') {
        sideVal = 1;
      } else if (u == 'SELL' || u == 'SELL_LIMIT' || u == 'SHORT') {
        sideVal = 2;
      }
    }

    return Position(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      side: sideVal,
      leverage: double.tryParse(json['leverage']?.toString() ?? '') ?? 0.0,
      capital: double.tryParse(json['capital']?.toString() ?? '') ?? 0.0,
      notional: double.tryParse(json['notional']?.toString() ?? '') ?? 0.0,
      entryPrice: double.tryParse(json['entry_price']?.toString() ?? '') ?? 0.0,
      entryQuantity: double.tryParse(json['entry_quantity']?.toString() ?? '') ?? 0.0,
      entryAmount: double.tryParse(json['entry_amount']?.toString() ?? '') ?? 0.0,
      timestamp: int.tryParse(json['timestamp']?.toString() ?? '') ?? 0,
    );
  }
}
