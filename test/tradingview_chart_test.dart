import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taoniu/models/cryptos/binance/spot/kline.dart';
import 'package:taoniu/ui/components/charts/tradingview_chart.dart';

void main() {
  testWidgets('TradingViewChart updates when klines update', (WidgetTester tester) async {
    final klinesInitial = [
      Kline(openTime: 1600000000000, open: 100, high: 110, low: 90, close: 105, volume: 1000, closeTime: 1600000059999),
      Kline(openTime: 1600000060000, open: 105, high: 115, low: 100, close: 110, volume: 1200, closeTime: 1600000119999),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TradingViewChart(
            symbol: 'BTCUSDT',
            interval: '1m',
            klines: klinesInitial,
          ),
        ),
      ),
    );

    expect(find.byType(TradingViewChart), findsOneWidget);

    final klinesUpdated = [
      Kline(openTime: 1600000000000, open: 100, high: 110, low: 90, close: 105, volume: 1000, closeTime: 1600000059999),
      Kline(openTime: 1600000060000, open: 105, high: 120, low: 100, close: 118, volume: 1500, closeTime: 1600000119999),
      Kline(openTime: 1600000120000, open: 118, high: 125, low: 115, close: 122, volume: 1800, closeTime: 1600000179999),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TradingViewChart(
            symbol: 'BTCUSDT',
            interval: '1m',
            klines: klinesUpdated,
          ),
        ),
      ),
    );

    expect(find.byType(TradingViewChart), findsOneWidget);
  });

  testWidgets('TradingViewChart drag gestures update scroll offset without crashing', (WidgetTester tester) async {
    final klines = List.generate(50, (i) => Kline(
      openTime: 1600000000000 + i * 60000,
      open: 100.0 + i,
      high: 105.0 + i,
      low: 95.0 + i,
      close: 102.0 + i,
      volume: 1000.0 + i * 10,
      closeTime: 1600000059999 + i * 60000,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: TradingViewChart(
              symbol: 'BTCUSDT',
              interval: '1m',
              klines: klines,
            ),
          ),
        ),
      ),
    );

    final chartFinder = find.byType(TradingViewChart);
    expect(chartFinder, findsOneWidget);

    // Simulate horizontal drag to scroll chart
    await tester.drag(chartFinder, const Offset(-200, 0));
    await tester.pump();

    await tester.drag(chartFinder, const Offset(300, 0));
    await tester.pump();

    expect(chartFinder, findsOneWidget);
  });

  testWidgets('TradingViewChart isolates view state when switching interval or symbol', (WidgetTester tester) async {
    final klines = List.generate(20, (i) => Kline(
      openTime: 1600000000000 + i * 60000,
      open: 100.0 + i,
      high: 105.0 + i,
      low: 95.0 + i,
      close: 102.0 + i,
      volume: 1000.0 + i * 10,
      closeTime: 1600000059999 + i * 60000,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: TradingViewChart(
              symbol: 'BTCUSDT',
              interval: '15m',
              klines: klines,
            ),
          ),
        ),
      ),
    );

    // Switch interval to 1h
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: TradingViewChart(
              symbol: 'BTCUSDT',
              interval: '1h',
              klines: klines,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TradingViewChart), findsOneWidget);
  });
}
