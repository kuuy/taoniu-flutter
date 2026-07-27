import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'ranking_controller.dart';

class TickersRankingPage extends GetView<TickersRankingController> {
  const TickersRankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(title: 'Tickers Ranking'),
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
            firstColumn: const DataColumn(
              label: Text('SYMBOL', style: TvTableTheme.headerTextStyle),
            ),
            remainingColumns: controller.fields
                .map((f) => DataColumn(
                      label: Text(
                        f.replaceAll('_', ' ').toUpperCase(),
                        style: TvTableTheme.headerTextStyle,
                      ),
                    ))
                .toList(),
            itemCount: controller.items.length,
            firstCellBuilder: (index) {
              final item = controller.items[index];
              final values = item.split(',');
              final symbol = values.isNotEmpty ? values[0] : '';
              return DataCell(
                Text(
                  symbol,
                  style: const TextStyle(
                    color: TvTableTheme.tvTextPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    letterSpacing: 0.3,
                  ),
                ),
              );
            },
            remainingCellsBuilder: (index) {
              final item = controller.items[index];
              final values = item.split(',');
              final fieldsValues = List.generate(
                controller.fields.length,
                (i) => (i + 1 < values.length) ? values[i + 1] : '',
              );
              return fieldsValues.map((val) {
                final numVal = double.tryParse(val);
                if (numVal != null) {
                  Color col = TvTableTheme.tvTextSecondary;
                  if (val.contains('.')) {
                    if (numVal > 0) col = TvTableTheme.tvGreen;
                    if (numVal < 0) col = TvTableTheme.tvRed;
                  }
                  return DataCell(
                    Text(
                      val,
                      style: TextStyle(
                        color: col,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  );
                }
                return DataCell(
                  Text(
                    val,
                    style: const TextStyle(
                      color: TvTableTheme.tvTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        );
      }),
    );
  }
}
