import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              children: controller.symbols.map((symbol) {
                return Obx(() {
                  final isSelected = controller.selectedSymbol.value == symbol;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(symbol),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : TvTableTheme.tvTextSecondary,
                        fontSize: 11.5,
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
              }).toList(),
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
}
