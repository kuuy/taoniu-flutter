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

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      side: int.tryParse(json['side']?.toString() ?? '') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 0.0,
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      timestamp: int.tryParse(json['timestamp']?.toString() ?? '') ?? 0,
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
    );
  }
}
