import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/binance/spot/scalping.dart';
import 'package:taoniu/routes/app_routes.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'package:taoniu/ui/components/pulsing_badge.dart';
import 'scalping_controller.dart';

class ScalpingPage extends GetView<ScalpingController> {
  const ScalpingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(title: 'Binance Spot Scalping 策略'),
      body: Column(
        children: [
          // 1. Top Filter Bar (Symbols & Side Selectors)
          _buildFilterBar(),

          // 2. Main Sticky Table / Loading State
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(TvTableTheme.tvGreen),
                  ),
                );
              }

              if (controller.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.blur_off_rounded, color: TvTableTheme.tvTextSecondary, size: 42),
                      const SizedBox(height: 10),
                      Text(
                        '暂无 ${controller.selectedSymbol.value} 剥头皮策略数据',
                        style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 13.5),
                      ),
                    ],
                  ),
                );
              }

              return EasyRefresh(
                onRefresh: () => controller.fetchScalping(isRefresh: true),
                onLoad: () => controller.loadMore(),
                child: TvTableTheme.buildStickyTable(
                  firstColumn: const DataColumn(label: Text('SYMBOL', style: TvTableTheme.headerTextStyle)),
                  remainingColumns: const [
                    DataColumn(label: Text('SIDE', style: TvTableTheme.headerTextStyle)),
                    DataColumn(label: Text('CAPITAL', style: TvTableTheme.headerTextStyle)),
                    DataColumn(label: Text('PRICE', style: TvTableTheme.headerTextStyle)),
                    DataColumn(label: Text('TAKE PRICE', style: TvTableTheme.headerTextStyle)),
                    DataColumn(label: Text('STOP PRICE', style: TvTableTheme.headerTextStyle)),
                    DataColumn(label: Text('STATUS', style: TvTableTheme.headerTextStyle)),
                  ],
                  itemCount: controller.items.length,
                  onSelectRow: (index) {
                    final item = controller.items[index];
                    _showScalpingActionSheet(context, item);
                  },
                  firstCellBuilder: (index) {
                    final item = controller.items[index];
                    return DataCell(
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            item.symbol,
                            style: const TextStyle(
                              color: TvTableTheme.tvTextPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  remainingCellsBuilder: (index) {
                    final item = controller.items[index];
                    final isBuy = item.isBuy;

                    return [
                      DataCell(
                        PulsingBadge(
                          label: item.sideLabel,
                          color: isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                          isLive: true,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${item.capital.toStringAsFixed(2)}',
                          style: TvTableTheme.numberTextStyle,
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${item.takePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: TvTableTheme.tvGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${item.stopPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: TvTableTheme.tvRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      DataCell(
                        _buildStatusChip(item.statusLabel),
                      ),
                    ];
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        border: Border(
          bottom: BorderSide(color: TvTableTheme.tvBorderColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('标的: ', style: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 11.5)),
                ...controller.symbols.map((symbol) {
                  return Obx(() {
                    final isSelected = controller.selectedSymbol.value == symbol;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(symbol),
                        visualDensity: VisualDensity.compact,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : TvTableTheme.tvTextSecondary,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: TvTableTheme.tvCanvasBg,
                        selectedColor: TvTableTheme.tvBlue,
                        side: BorderSide(
                          color: isSelected ? TvTableTheme.tvBlue : TvTableTheme.tvBorderColor,
                        ),
                        onSelected: (_) => controller.changeSymbol(symbol),
                      ),
                    );
                  });
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Side Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('方向: ', style: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 11.5)),
                ...controller.sides.map((side) {
                  return Obx(() {
                    final isSelected = controller.selectedSide.value == side;
                    Color sideColor = TvTableTheme.tvBlue;
                    if (side == 'BUY') sideColor = TvTableTheme.tvGreen;
                    if (side == 'SELL') sideColor = TvTableTheme.tvRed;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(side),
                        visualDensity: VisualDensity.compact,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : TvTableTheme.tvTextSecondary,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: TvTableTheme.tvCanvasBg,
                        selectedColor: sideColor,
                        side: BorderSide(
                          color: isSelected ? sideColor : TvTableTheme.tvBorderColor,
                        ),
                        onSelected: (_) => controller.changeSide(side),
                      ),
                    );
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String statusLabel) {
    Color color;
    switch (statusLabel) {
      case 'RUNNING':
        color = TvTableTheme.tvGreen;
        break;
      case 'FILLED':
        color = TvTableTheme.tvBlue;
        break;
      case 'CANCELLED':
        color = TvTableTheme.tvRed;
        break;
      default:
        color = TvTableTheme.tvAmber;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showScalpingActionSheet(BuildContext context, Scalping item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: TvTableTheme.tvHeaderBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: TvTableTheme.tvBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      item.symbol,
                      style: const TextStyle(
                        color: TvTableTheme.tvTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PulsingBadge(
                      label: item.sideLabel,
                      color: item.isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                      isLive: true,
                    ),
                  ],
                ),
                Text(
                  '策略价: \$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item.isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.exposure_rounded, color: TvTableTheme.tvBlue),
              title: const Text('带入 Symbol 与策略价格至 Positions Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotPositionsCalc,
                  arguments: {
                    'symbol': item.symbol,
                    'entryPrice': item.price,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate_rounded, color: TvTableTheme.tvCyan),
              title: const Text('带入 Symbol 与策略价格至 Gambling Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotGamblingCalc,
                  arguments: {
                    'symbol': item.symbol,
                    'entryPrice': item.price,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: TvTableTheme.tvAmber),
              title: const Text('复制 Symbol 名称', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.symbol));
                Get.back();
                Get.snackbar('成功', '已复制 ${item.symbol} 到剪贴板', duration: const Duration(seconds: 2));
              },
            ),
          ],
        ),
      ),
    );
  }
}
