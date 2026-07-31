class Order {
  final String id;
  final String symbol;
  final int orderId;
  final String type;
  final int side;
  final double price;
  final double quantity;
  final int openTime;
  final int updateTime;
  final bool reduceOnly;
  final dynamic status;

  Order({
    required this.id,
    required this.symbol,
    required this.orderId,
    required this.type,
    required this.side,
    required this.price,
    required this.quantity,
    required this.openTime,
    required this.updateTime,
    required this.reduceOnly,
    required this.status,
  });

  bool get isBuy => side == 1;
  double get amount => price * quantity;
  String get statusText => status?.toString() ?? '';

  String formatTime(int timestamp) {
    if (timestamp <= 0) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp.toString().length == 10 ? timestamp * 1000 : timestamp);
    return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  factory Order.fromJson(Map<String, dynamic> json) {
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

    return Order(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      orderId: int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? '',
      side: sideVal,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 0.0,
      openTime: int.tryParse(json['open_time']?.toString() ?? '') ?? 0,
      updateTime: int.tryParse(json['update_time']?.toString() ?? '') ?? 0,
      reduceOnly: json['reduce_only'] == true || json['reduce_only'] == 'true',
      status: json['status']?.toString() ?? '',
    );
  }
}
