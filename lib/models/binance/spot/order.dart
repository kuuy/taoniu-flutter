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
  final int status;

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

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      orderId: int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? '',
      side: int.tryParse(json['side']?.toString() ?? '') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 0.0,
      openTime: int.tryParse(json['open_time']?.toString() ?? '') ?? 0,
      updateTime: int.tryParse(json['update_time']?.toString() ?? '') ?? 0,
      reduceOnly: json['reduce_only'] == true || json['reduce_only'] == 'true',
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
    );
  }
}
