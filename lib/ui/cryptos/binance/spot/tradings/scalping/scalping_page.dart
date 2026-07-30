import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'scalping_controller.dart';

class TradingsScalpingPage extends GetView<TradingsScalpingController> {
  const TradingsScalpingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(title: 'Tradings Scalping 交易流'),
      body: Column(
        children: [
          // 1. Top Symbol Selector Bar
          _buildFilterBar(),

          // 2. Main Data Table with Pull-to-Refresh
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
                      const Icon(Icons.show_chart_rounded, color: TvTableTheme.tvTextSecondary, size: 42),
                      const SizedBox(height: 10),
                      Text(
                        '暂无 ${controller.selectedSymbol.value} 高频对冲交易明细',
                        style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 13.5),
                      ),
                    ],
                  ),
                );
              }

              return EasyRefresh(
                onRefresh: () => controller.fetchListings(isRefresh: true),
                onLoad: () => controller.loadMore(),
                child: TvTableTheme.buildStickyTable(
                  firstColumn: const DataColumn(label: Text('SYMBOL', style: TvTableTheme.headerTextStyle)),
                  remainingColumns: const [
                    DataColumn(label: Text('BUY PRICE', style: TvTableTheme.headerTextStyle)),
                    DataColumn(label: Text('SELL PRICE', style: TvTableTheme.headerTextStyle)),
                    DataColumn(label: Text('BUY QTY', style: TvTableTheme.headerTextStyle)),
                    DataColumn(label: Text('SELL QTY', style: TvTableTheme.headerTextStyle)),
                    DataColumn(label: Text('STATUS', style: TvTableTheme.headerTextStyle)),
                  ],
                  itemCount: controller.items.length,
                  firstCellBuilder: (index) {
                    final item = controller.items[index];
                    return DataCell(
                      Row(
                        children: [
                          const Icon(Icons.currency_exchange_rounded, color: TvTableTheme.tvBlue, size: 14),
                          const SizedBox(width: 5),
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
                    return [
                      DataCell(
                        Text(
                          '\$${item.buyPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: TvTableTheme.tvGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${item.sellPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: TvTableTheme.tvRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.buyQuantity.toStringAsFixed(4),
                          style: TvTableTheme.numberTextStyle,
                        ),
                      ),
                      DataCell(
                        Text(
                          item.sellQuantity.toStringAsFixed(4),
                          style: TvTableTheme.numberTextStyle,
                        ),
                      ),
                      DataCell(
                        _buildStatusChip(item.status.toString()),
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
      child: SingleChildScrollView(
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
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    if (status == '1' || status.toUpperCase() == 'COMPLETED') {
      color = TvTableTheme.tvGreen;
      label = 'COMPLETED';
    } else if (status == '0' || status.toUpperCase() == 'RUNNING') {
      color = TvTableTheme.tvBlue;
      label = 'RUNNING';
    } else {
      color = TvTableTheme.tvAmber;
      label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold),
      ),
    );
  }
}
