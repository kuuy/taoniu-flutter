class PositionCalcTrading {
  final double buyPrice;
  final double sellPrice;
  final double quantity;
  final double entryPrice;
  final double entryQuantity;

  PositionCalcTrading({
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.entryPrice,
    required this.entryQuantity,
  });

  factory PositionCalcTrading.fromJson(Map<String, dynamic> json) {
    return PositionCalcTrading(
      buyPrice: double.tryParse(json['buy_price']?.toString() ?? '') ?? 0.0,
      sellPrice: double.tryParse(json['sell_price']?.toString() ?? '') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 0.0,
      entryPrice: double.tryParse(json['entry_price']?.toString() ?? '') ?? 0.0,
      entryQuantity: double.tryParse(json['entry_quantity']?.toString() ?? '') ?? 0.0,
    );
  }
}

class PositionCalcResult {
  final double takePrice;
  final double stopPrice;
  final List<PositionCalcTrading> tradings;

  PositionCalcResult({
    required this.takePrice,
    required this.stopPrice,
    required this.tradings,
  });

  factory PositionCalcResult.fromJson(Map<String, dynamic> json) {
    var tradingsList = json['tradings'] as List?;
    List<PositionCalcTrading> tradings = tradingsList != null
        ? tradingsList.map((e) => PositionCalcTrading.fromJson(e as Map<String, dynamic>)).toList()
        : [];

    return PositionCalcResult(
      takePrice: double.tryParse(json['take_price']?.toString() ?? '') ?? 0.0,
      stopPrice: double.tryParse(json['stop_price']?.toString() ?? '') ?? 0.0,
      tradings: tradings,
    );
  }
}
