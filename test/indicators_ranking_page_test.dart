import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/components/app_scroll_behavior.dart';
import 'package:taoniu/ui/cryptos/binance/spot/indicators/ranking/ranking_controller.dart';
import 'package:taoniu/ui/cryptos/binance/spot/indicators/ranking/ranking_page.dart';

class TestIndicatorsRankingController extends IndicatorsRankingController {
  @override
  Future<void> fetchRanking() async {
    isLoading(true);
    rankingData['1m'] = [
      'BTCUSDT,1.0,2.0,3.0,4.0,5.0,0.5,10.0,2.0,1.5,3.0',
      'ETHUSDT,1.1,2.1,3.1,4.1,5.1,0.6,10.1,2.1,1.6,3.1',
    ];
    isLoading(false);
  }
}

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('IndicatorsRankingPage renders fixed symbol column and scrollable fields with TradingView style',
      (WidgetTester tester) async {
    final controller = Get.put<IndicatorsRankingController>(TestIndicatorsRankingController());
    controller.fetchRanking();

    await tester.pumpWidget(
      const GetMaterialApp(
        scrollBehavior: AppScrollBehavior(),
        home: IndicatorsRankingPage(),
      ),
    );
    await tester.pump();

    expect(find.text('1m'), findsOneWidget);
    expect(find.text('15m'), findsOneWidget);
    expect(find.text('4h'), findsOneWidget);
    expect(find.text('1d'), findsOneWidget);

    expect(find.text('SYMBOL'), findsOneWidget);
    expect(find.text('BTCUSDT'), findsOneWidget);
    expect(find.text('ETHUSDT'), findsOneWidget);
    expect(find.text('R1'), findsOneWidget);
    expect(find.text('S1'), findsOneWidget);
    expect(find.text('POC'), findsOneWidget);

    // Verify DataTable instances (one for sticky first column, one for scrollable fields)
    expect(find.byType(DataTable), findsNWidgets(2));
  });

  testWidgets('IndicatorsRankingPage switches intervals on tap',
      (WidgetTester tester) async {
    final controller = Get.put<IndicatorsRankingController>(TestIndicatorsRankingController());
    controller.fetchRanking();

    await tester.pumpWidget(
      const GetMaterialApp(
        scrollBehavior: AppScrollBehavior(),
        home: IndicatorsRankingPage(),
      ),
    );
    await tester.pump();

    expect(controller.selectedInterval.value, '1m');

    await tester.tap(find.text('15m'));
    await tester.pump();

    expect(controller.selectedInterval.value, '15m');
  });

  testWidgets('IndicatorsRankingPage supports mouse drag scrolling',
      (WidgetTester tester) async {
    final controller = Get.put<IndicatorsRankingController>(TestIndicatorsRankingController());
    controller.fetchRanking();

    await tester.pumpWidget(
      const GetMaterialApp(
        scrollBehavior: AppScrollBehavior(),
        home: IndicatorsRankingPage(),
      ),
    );
    await tester.pump();

    final scrollableFinder = find.byType(SingleChildScrollView).last;
    expect(scrollableFinder, findsOneWidget);

    // Simulate mouse drag horizontally
    final gesture = await tester.startGesture(
      tester.getCenter(scrollableFinder),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(-300, 0));
    await gesture.up();
    await tester.pump();

    expect(find.byType(IndicatorsRankingPage), findsOneWidget);
  });
}
