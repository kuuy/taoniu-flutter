class GamblingPlan {
  final double price;
  final double quantity;
  final double takeProfit;
  final double amount;
  final double profit;

  GamblingPlan({
    required this.price,
    required this.quantity,
    required this.takeProfit,
    required this.amount,
    required this.profit,
  });

  factory GamblingPlan.fromJson(Map<String, dynamic> json) {
    return GamblingPlan(
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 0.0,
      takeProfit: double.tryParse(json['take_profit']?.toString() ?? '') ?? 0.0,
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      profit: double.tryParse(json['profit']?.toString() ?? '') ?? 0.0,
    );
  }
}

class GamblingCalcResult {
  final double takePrice;
  final double stopPrice;
  final double planProfit;
  final List<GamblingPlan> plans;

  GamblingCalcResult({
    required this.takePrice,
    required this.stopPrice,
    required this.planProfit,
    required this.plans,
  });

  factory GamblingCalcResult.fromJson(Map<String, dynamic> json) {
    var plansList = json['plans'] as List?;
    List<GamblingPlan> plans = plansList != null
        ? plansList.map((e) => GamblingPlan.fromJson(e as Map<String, dynamic>)).toList()
        : [];

    return GamblingCalcResult(
      takePrice: double.tryParse(json['take_price']?.toString() ?? '') ?? 0.0,
      stopPrice: double.tryParse(json['stop_price']?.toString() ?? '') ?? 0.0,
      planProfit: double.tryParse(json['plan_profit']?.toString() ?? '') ?? 0.0,
      plans: plans,
    );
  }
}
