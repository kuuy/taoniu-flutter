import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'strategies_controller.dart';

class StrategiesPage extends GetView<StrategiesController> {
  const StrategiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(title: 'Strategies'),
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
              DataColumn(label: Text('INDICATOR', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('SIGNAL', style: TvTableTheme.headerTextStyle)),
              DataColumn(label: Text('PRICE', style: TvTableTheme.headerTextStyle)),
            ],
            itemCount: controller.items.length,
            firstCellBuilder: (index) {
              final item = controller.items[index];
              return DataCell(Text(item.symbol, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontWeight: FontWeight.w600, fontSize: 12.5, letterSpacing: 0.3)));
            },
            remainingCellsBuilder: (index) {
              final item = controller.items[index];
              final sigStr = item.signal.toString().toUpperCase();
              final isBuy = sigStr == '1' || sigStr == 'BUY';
              final isSell = sigStr == '-1' || sigStr == 'SELL';
              final sigColor = isBuy
                  ? TvTableTheme.tvGreen
                  : (isSell ? TvTableTheme.tvRed : TvTableTheme.tvTextSecondary);
              return [
                DataCell(Text(item.indicator, style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12))),
                DataCell(
                  Text(
                    item.signal.toString(),
                    style: TextStyle(
                      color: sigColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataCell(Text(item.price.toString(), style: TvTableTheme.numberTextStyle)),
              ];
            },
          ),
        );
      }),
    );
  }
}
