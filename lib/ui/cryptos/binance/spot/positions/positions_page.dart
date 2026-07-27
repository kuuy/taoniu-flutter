import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'positions_controller.dart';

class PositionsPage extends GetView<PositionsController> {
  const PositionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(title: 'Positions'),
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
              DataColumn(label: Text('SIDE', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('LEVERAGE', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('CAPITAL', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('NOTIONAL', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('ENTRY PRICE', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('ENTRY QTY', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('ENTRY AMOUNT', style: TvTableTheme.headerTextStyle)),
            ],
            itemCount: controller.items.length,
            firstCellBuilder: (index) {
              final item = controller.items[index];
              return DataCell(Text(item.symbol, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontWeight: FontWeight.w600, fontSize: 12.5, letterSpacing: 0.3)));
            },
            remainingCellsBuilder: (index) {
              final item = controller.items[index];
              final isLong = item.side == 1 || item.side.toString().toUpperCase() == 'LONG' || item.side.toString().toUpperCase() == 'BUY';
              return [
                DataCell(
                  Text(
                    item.side.toString(),
                    style: TextStyle(
                      color: isLong ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataCell(Text('${item.leverage}x', style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.capital.toString(), style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.notional.toString(), style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.entryPrice.toString(), style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.entryQuantity.toString(), style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.entryAmount.toString(), style: TvTableTheme.numberTextStyle)),
              ];
            },
          ),
        );
      }),
    );
  }
}
