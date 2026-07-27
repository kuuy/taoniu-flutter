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
      appBar: TvTableTheme.buildAppBar(title: 'Analysis Tradings Scalping'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TvTableTheme.tvGreen),
            ),
          );
        }

        if (controller.scalpingList.isEmpty) {
          return const Center(
            child: Text(
              'No listings available',
              style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.scalpingList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ScalpingChart(items: controller.scalpingList);
            }
            final item = controller.scalpingList[index - 1];
            return _buildScalpingListItem(item);
          },
        );
      }),
    );
  }

  Widget _buildScalpingListItem(Scalping item) {
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
                        color: TvTableTheme.tvTextPrimary,
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
                        color: TvTableTheme.tvTextPrimary,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
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
                        color: TvTableTheme.tvTextPrimary,
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
                        color: TvTableTheme.tvTextPrimary,
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

    final chartItems = items.length > 10 ? items.sublist(0, 10) : items;

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
      height: 210,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: TvTableTheme.tvCanvasBg,
        border: Border(
          bottom: BorderSide(color: TvTableTheme.tvBorderColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$maxVal',
                  style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 10),
                ),
                Text(
                  '${maxVal ~/ 2}',
                  style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 10),
                ),
                const Text(
                  '0',
                  style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 10),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          Expanded(
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
          ),
        ],
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
    final double chartHeight = size.height - xAxisHeight;
    final double baselineY = chartHeight / 2.0;

    final gridPaint = Paint()
      ..color = const Color(0xFF2A2E39)
      ..strokeWidth = 0.8;

    final baselinePaint = Paint()
      ..color = const Color(0xFF434651)
      ..strokeWidth = 1.0;

    final greenPaint = Paint()..color = const Color(0xFF66BB6A);
    final redPaint = Paint()..color = const Color(0xFFEF5350);

    // Grid lines
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), gridPaint);
    canvas.drawLine(Offset(0, baselineY / 2), Offset(size.width, baselineY / 2), gridPaint);
    canvas.drawLine(Offset(0, baselineY), Offset(size.width, baselineY), baselinePaint);
    canvas.drawLine(Offset(0, baselineY + baselineY / 2), Offset(size.width, baselineY + baselineY / 2), gridPaint);
    canvas.drawLine(Offset(0, chartHeight), Offset(size.width, chartHeight), gridPaint);

    final int count = items.length;
    final double slotWidth = size.width / count;
    final double barWidth = (slotWidth * 0.65).clamp(8.0, 36.0);
    final double maxBarHeight = baselineY - 4.0;

    for (int i = 0; i < count; i++) {
      final item = items[i];
      final double centerX = slotWidth * i + slotWidth / 2.0;
      final double barLeft = centerX - barWidth / 2.0;
      final double barRight = centerX + barWidth / 2.0;

      // Buy bar (Green UP)
      final double buyRatio = (item.buysCount / maxVal).clamp(0.0, 1.0);
      final double buyHeight = buyRatio * maxBarHeight;
      if (buyHeight > 0) {
        final buyRect = Rect.fromLTRB(barLeft, baselineY - buyHeight, barRight, baselineY);
        canvas.drawRect(buyRect, greenPaint);
      }

      // Sell bar (Red DOWN)
      final double sellRatio = (item.sellsCount / maxVal).clamp(0.0, 1.0);
      final double sellHeight = sellRatio * maxBarHeight;
      if (sellHeight > 0) {
        final sellRect = Rect.fromLTRB(barLeft, baselineY, barRight, baselineY + sellHeight);
        canvas.drawRect(sellRect, redPaint);
      }

      // Date label
      final String shortDate = item.day.length >= 10
          ? '${item.day.substring(5, 7)}/${item.day.substring(8, 10)}'
          : item.day;

      final textSpan = TextSpan(
        text: shortDate,
        style: const TextStyle(
          color: TvTableTheme.tvTextSecondary,
          fontSize: 10.5,
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

