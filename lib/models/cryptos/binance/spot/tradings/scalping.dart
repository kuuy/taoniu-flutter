class TradingInfo {
  final String id;
  final String symbol;
  final String scalpingId;
  final String planId;
  final double buyPrice;
  final double sellPrice;
  final double buyQuantity;
  final double sellQuantity;
  final String buyOrderId;
  final String sellOrderId;
  final int status;
  final int createdAt;
  final int updatedAt;

  TradingInfo({
    required this.id,
    required this.symbol,
    required this.scalpingId,
    required this.planId,
    required this.buyPrice,
    required this.sellPrice,
    required this.buyQuantity,
    required this.sellQuantity,
    required this.buyOrderId,
    required this.sellOrderId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TradingInfo.fromJson(Map<String, dynamic> json) {
    return TradingInfo(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      scalpingId: json['scalping_id']?.toString() ?? '',
      planId: json['plan_id']?.toString() ?? '',
      buyPrice: double.tryParse(json['buy_price']?.toString() ?? '') ?? 0.0,
      sellPrice: double.tryParse(json['sell_price']?.toString() ?? '') ?? 0.0,
      buyQuantity: double.tryParse(json['buy_quantity']?.toString() ?? '') ?? 0.0,
      sellQuantity: double.tryParse(json['sell_quantity']?.toString() ?? '') ?? 0.0,
      buyOrderId: json['buy_order_id']?.toString() ?? '',
      sellOrderId: json['sell_order_id']?.toString() ?? '',
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: int.tryParse(json['created_at']?.toString() ?? '') ?? 0,
      updatedAt: int.tryParse(json['updated_at']?.toString() ?? '') ?? 0,
    );
  }
}
