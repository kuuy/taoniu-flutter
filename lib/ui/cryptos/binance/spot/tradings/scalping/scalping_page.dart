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
      appBar: TvTableTheme.buildAppBar(title: 'Tradings Scalping'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TvTableTheme.tvGreen),
            ),
          );
        }

        if (controller.items.isEmpty) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 14),
            ),
          );
        }

        return Container(
          color: TvTableTheme.tvCanvasBg,
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
              return DataCell(Text(item.symbol, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontWeight: FontWeight.w600, fontSize: 12.5, letterSpacing: 0.3)));
            },
            remainingCellsBuilder: (index) {
              final item = controller.items[index];
              return [
                DataCell(Text(item.buyPrice.toString(), style: TextStyle(color: TvTableTheme.tvGreen, fontSize: 12, fontWeight: FontWeight.w500, fontFeatures: const [FontFeature.tabularFigures()]))),
                DataCell(Text(item.sellPrice.toString(), style: TextStyle(color: TvTableTheme.tvRed, fontSize: 12, fontWeight: FontWeight.w500, fontFeatures: const [FontFeature.tabularFigures()]))),
                DataCell(Text(item.buyQuantity.toString(), style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.sellQuantity.toString(), style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.status.toString(), style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12))),
              ];
            },
          ),
        );
      }),
    );
  }
}
