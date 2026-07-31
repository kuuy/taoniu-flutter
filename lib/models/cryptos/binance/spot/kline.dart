class Kline {
  final int openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final int closeTime;

  Kline({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
  });

  factory Kline.fromJson(dynamic json) {
    if (json is List) {
      return Kline(
        openTime: int.tryParse(json[0].toString()) ?? 0,
        open: double.tryParse(json[1].toString()) ?? 0.0,
        high: double.tryParse(json[2].toString()) ?? 0.0,
        low: double.tryParse(json[3].toString()) ?? 0.0,
        close: double.tryParse(json[4].toString()) ?? 0.0,
        volume: double.tryParse(json[5].toString()) ?? 0.0,
        closeTime: json.length > 6 ? (int.tryParse(json[6].toString()) ?? 0) : 0,
      );
    } else if (json is Map<String, dynamic>) {
      return Kline(
        openTime: int.tryParse(json['openTime']?.toString() ?? json['open_time']?.toString() ?? '0') ?? 0,
        open: double.tryParse(json['open']?.toString() ?? '0') ?? 0.0,
        high: double.tryParse(json['high']?.toString() ?? '0') ?? 0.0,
        low: double.tryParse(json['low']?.toString() ?? '0') ?? 0.0,
        close: double.tryParse(json['close']?.toString() ?? '0') ?? 0.0,
        volume: double.tryParse(json['volume']?.toString() ?? '0') ?? 0.0,
        closeTime: int.tryParse(json['closeTime']?.toString() ?? json['close_time']?.toString() ?? '0') ?? 0,
      );
    }
    return Kline(openTime: 0, open: 0, high: 0, low: 0, close: 0, volume: 0, closeTime: 0);
  }
}
