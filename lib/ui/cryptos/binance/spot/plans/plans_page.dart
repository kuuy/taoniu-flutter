import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'plans_controller.dart';

class PlansPage extends GetView<BinanceSpotPlansController> {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(title: 'Plans'),
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
              DataColumn(label: Text('PRICE', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('QUANTITY', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('AMOUNT', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('STATUS', style: TvTableTheme.headerTextStyle)),
            ],
            itemCount: controller.items.length,
            firstCellBuilder: (index) {
              final item = controller.items[index];
              return DataCell(Text(item.symbol, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontWeight: FontWeight.w600, fontSize: 12.5, letterSpacing: 0.3)));
            },
            remainingCellsBuilder: (index) {
              final item = controller.items[index];
              final isBuy = item.side == 1 || item.side.toString().toUpperCase() == 'BUY';
              return [
                DataCell(
                  Text(
                    item.side.toString(),
                    style: TextStyle(
                      color: isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataCell(Text(item.price.toString(), style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.quantity.toString(), style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.amount.toString(), style: TvTableTheme.numberTextStyle)),
                DataCell(Text(item.status.toString(), style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12))),
              ];
            },
          ),
        );
      }),
    );
  }
}
