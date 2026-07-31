class Scalping {
  final String id;
  final String day;
  final int buysCount;
  final int sellsCount;
  final String buysAmount;
  final String sellsAmount;
  final String profit;
  final String additiveProfit;

  Scalping({
    required this.id,
    required this.day,
    required this.buysCount,
    required this.sellsCount,
    required this.buysAmount,
    required this.sellsAmount,
    required this.profit,
    required this.additiveProfit,
  });

  factory Scalping.fromJson(Map<String, dynamic> json) {
    return Scalping(
      id: json['id'] as String,
      day: json['day'] as String,
      buysCount: json['buys_count'] as int,
      sellsCount: json['sells_count'] as int,
      buysAmount: json['buys_amount'] as String,
      sellsAmount: json['sells_amount'] as String,
      profit: json['profit'] as String,
      additiveProfit: json['additive_profit'] as String,
    );
  }
}
