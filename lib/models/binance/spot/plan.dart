class Plan {
  final String id;
  final String symbol;
  final int side;
  final double price;
  final double quantity;
  final double amount;
  final int timestamp;
  final int status;

  Plan({
    required this.id,
    required this.symbol,
    required this.side,
    required this.price,
    required this.quantity,
    required this.amount,
    required this.timestamp,
    required this.status,
  });

  bool get isBuy => side == 1;

  factory Plan.fromJson(Map<String, dynamic> json) {
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

    return Plan(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      side: sideVal,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 0.0,
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      timestamp: int.tryParse(json['timestamp']?.toString() ?? '') ?? 0,
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
    );
  }
}
