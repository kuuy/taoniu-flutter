class Strategy {
  final String id;
  final String symbol;
  final String indicator;
  final int signal;
  final double price;
  final int timestamp;

  Strategy({
    required this.id,
    required this.symbol,
    required this.indicator,
    required this.signal,
    required this.price,
    required this.timestamp,
  });

  bool get isBuy => signal == 1;
  bool get isSell => signal == -1 || signal == 2;
  String get signalLabel => isBuy ? 'BUY' : (isSell ? 'SELL' : 'HOLD');

  factory Strategy.fromJson(Map<String, dynamic> json) {
    final rawSig = json['signal']?.toString() ?? '';
    int sigVal = int.tryParse(rawSig) ?? 0;
    if (sigVal == 0) {
      final u = rawSig.trim().toUpperCase();
      if (u == 'BUY' || u == '1') sigVal = 1;
      if (u == 'SELL' || u == '-1' || u == '2') sigVal = -1;
    }

    return Strategy(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      indicator: json['indicator']?.toString() ?? '',
      signal: sigVal,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      timestamp: int.tryParse(json['timestamp']?.toString() ?? '') ?? 0,
    );
  }
}
