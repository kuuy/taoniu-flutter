import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/binance/spot/analysis/tradings/scalping.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'scalping_controller.dart';

class AnalysisTradingsScalpingPage extends GetView<AnalysisTradingsScalpingController> {
  const AnalysisTradingsScalpingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(title: '刷单交易分析'),
      body: Obx(() {
        if (controller.isLoading.value && controller.scalpingList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TvTableTheme.tvGreen),
            ),
          );
        }

        if (controller.scalpingList.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchListings,
            color: TvTableTheme.tvGreen,
            backgroundColor: TvTableTheme.tvHeaderBg,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.analytics_outlined,
                      size: 48,
                      color: TvTableTheme.tvTextSecondary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '暂无刷单分析数据',
                      style: TextStyle(
                        color: TvTableTheme.tvTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.fetchListings,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('重新加载'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TvTableTheme.tvHeaderBg,
                        foregroundColor: TvTableTheme.tvTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchListings,
          color: TvTableTheme.tvGreen,
          backgroundColor: TvTableTheme.tvHeaderBg,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.scalpingList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ScalpingChart(items: controller.scalpingList);
              }
              final item = controller.scalpingList[index - 1];
              return _buildScalpingListItem(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildScalpingListItem(Scalping item) {
    final double profitVal = double.tryParse(item.profit) ?? 0.0;
    final double addProfitVal = double.tryParse(item.additiveProfit) ?? 0.0;

    final profitColor = profitVal > 0
        ? TvTableTheme.tvGreen
        : (profitVal < 0 ? TvTableTheme.tvRed : TvTableTheme.tvTextPrimary);
    final profitPrefix = profitVal > 0 ? '+' : '';

    final addProfitColor = addProfitVal > 0
        ? TvTableTheme.tvGreen
        : (addProfitVal < 0 ? TvTableTheme.tvRed : TvTableTheme.tvTextPrimary);
    final addProfitPrefix = addProfitVal > 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: const BoxDecoration(
        color: TvTableTheme.tvCanvasBg,
        border: Border(
          bottom: BorderSide(color: TvTableTheme.tvBorderColor, width: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.day,
            style: const TextStyle(
              color: TvTableTheme.tvTextPrimary,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '买入笔数',
                      style: TextStyle(
                        color: TvTableTheme.tvTextSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.buysCount}',
                      style: const TextStyle(
                        color: TvTableTheme.tvGreen,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '卖出笔数',
                      style: TextStyle(
                        color: TvTableTheme.tvTextSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.sellsCount}',
                      style: const TextStyle(
                        color: TvTableTheme.tvRed,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '买入金额',
                      style: TextStyle(
                        color: TvTableTheme.tvTextSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.buysAmount,
                      style: const TextStyle(
                        color: TvTableTheme.tvGreen,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '卖出金额',
                      style: TextStyle(
                        color: TvTableTheme.tvTextSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.sellsAmount,
                      style: const TextStyle(
                        color: TvTableTheme.tvRed,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '当日收益',
                      style: TextStyle(
                        color: TvTableTheme.tvTextSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$profitPrefix${item.profit}',
                      style: TextStyle(
                        color: profitColor,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '累计收益',
                      style: TextStyle(
                        color: TvTableTheme.tvTextSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$addProfitPrefix${item.additiveProfit}',
                      style: TextStyle(
                        color: addProfitColor,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ScalpingChart extends StatelessWidget {
  final List<Scalping> items;

  const ScalpingChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final rawItems = items.length > 10 ? items.sublist(0, 10) : items;
    final chartItems = rawItems.reversed.toList();

    int maxVal = 0;
    for (var item in chartItems) {
      if (item.buysCount > maxVal) maxVal = item.buysCount;
      if (item.sellsCount > maxVal) maxVal = item.sellsCount;
    }
    if (maxVal == 0) maxVal = 100;
    if (maxVal <= 50) {
      maxVal = 50;
    } else if (maxVal <= 100) {
      maxVal = 100;
    } else {
      maxVal = ((maxVal + 49) ~/ 50) * 50;
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: TvTableTheme.tvCanvasBg,
        border: Border(
          bottom: BorderSide(color: TvTableTheme.tvBorderColor, width: 1.0),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: ScalpingChartPainter(
              items: chartItems,
              maxVal: maxVal,
            ),
          );
        },
      ),
    );
  }
}

class ScalpingChartPainter extends CustomPainter {
  final List<Scalping> items;
  final int maxVal;

  ScalpingChartPainter({
    required this.items,
    required this.maxVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    const double xAxisHeight = 22.0;
    const double leftPadding = 32.0;
    final double chartWidth = size.width - leftPadding;
    final double chartHeight = size.height - xAxisHeight;
    final double baselineY = chartHeight / 2.0;

    final gridPaint = Paint()
      ..color = TvTableTheme.tvBorderColor
      ..strokeWidth = 0.8;

    final baselinePaint = Paint()
      ..color = const Color(0xFF434651)
      ..strokeWidth = 1.0;

    final greenPaint = Paint()..color = TvTableTheme.tvGreen;
    final redPaint = Paint()..color = TvTableTheme.tvRed;

    final yPositions = [
      0.0,
      baselineY / 2,
      baselineY,
      baselineY + baselineY / 2,
      chartHeight,
    ];

    final yLabels = [
      '$maxVal',
      '${maxVal ~/ 2}',
      '0',
      '${maxVal ~/ 2}',
      '$maxVal',
    ];

    for (int i = 0; i < yPositions.length; i++) {
      final y = yPositions[i];
      final paintStyle = (i == 2) ? baselinePaint : gridPaint;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), paintStyle);

      final textSpan = TextSpan(
        text: yLabels[i],
        style: TextStyle(
          color: i == 2 ? TvTableTheme.tvTextPrimary : TvTableTheme.tvTextSecondary,
          fontSize: 9.5,
          fontWeight: i == 2 ? FontWeight.bold : FontWeight.normal,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      double labelY = y - textPainter.height / 2;
      if (i == 0) labelY = y;
      if (i == yPositions.length - 1) labelY = y - textPainter.height;

      textPainter.paint(canvas, Offset(0, labelY));
    }

    final int count = items.length;
    final double slotWidth = chartWidth / count;
    final double barWidth = (slotWidth * 0.60).clamp(6.0, 32.0);
    final double maxBarHeight = baselineY - 4.0;

    for (int i = 0; i < count; i++) {
      final item = items[i];
      final double centerX = leftPadding + slotWidth * i + slotWidth / 2.0;
      final double barLeft = centerX - barWidth / 2.0;
      final double barRight = centerX + barWidth / 2.0;

      final double buyRatio = (item.buysCount / maxVal).clamp(0.0, 1.0);
      final double buyHeight = buyRatio * maxBarHeight;
      if (buyHeight > 0) {
        final buyRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(barLeft, baselineY - buyHeight, barRight, baselineY),
          const Radius.circular(2),
        );
        canvas.drawRRect(buyRect, greenPaint);
      }

      final double sellRatio = (item.sellsCount / maxVal).clamp(0.0, 1.0);
      final double sellHeight = sellRatio * maxBarHeight;
      if (sellHeight > 0) {
        final sellRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(barLeft, baselineY, barRight, baselineY + sellHeight),
          const Radius.circular(2),
        );
        canvas.drawRRect(sellRect, redPaint);
      }

      final String shortDate = item.day.length >= 10
          ? '${item.day.substring(5, 7)}/${item.day.substring(8, 10)}'
          : item.day;

      final textSpan = TextSpan(
        text: shortDate,
        style: const TextStyle(
          color: TvTableTheme.tvTextSecondary,
          fontSize: 10.0,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2.0, chartHeight + 4.0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScalpingChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.maxVal != maxVal;
  }
}
