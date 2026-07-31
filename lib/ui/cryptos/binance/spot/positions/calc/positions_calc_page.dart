import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'positions_calc_controller.dart';

class PositionsCalcPage extends GetView<PositionsCalcController> {
  const PositionsCalcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(title: 'Positions Calc (Binance Spot)'),
      body: Column(
        children: [
          _buildFormCard(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(TvTableTheme.tvGreen),
                  ),
                );
              }

              final res = controller.result.value;
              if (res == null) {
                return const Center(
                  child: Text(
                    '暂无计算数据，请输入参数后点击计算',
                    style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 14),
                  ),
                );
              }

              return Column(
                children: [
                  _buildSummaryCards(res),
                  Expanded(
                    child: _buildTradingsTable(res),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TvTableTheme.tvBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.symbolController,
                  style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Symbol',
                    labelStyle: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 12),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller.maxCapitalController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Max Capital',
                    labelStyle: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 12),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBlue),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.entryPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Entry Price',
                    labelStyle: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 12),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller.entryQuantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Entry Qty',
                    labelStyle: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 12),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: controller.calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TvTableTheme.tvBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('计算', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(dynamic res) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        children: [
          _buildSummaryCard(
            '止盈目标价 (Take Price)',
            res.takePrice.toString(),
            TvTableTheme.tvGreen,
            Icons.arrow_upward_rounded,
          ),
          const SizedBox(width: 10),
          _buildSummaryCard(
            '止损触发价 (Stop Price)',
            res.stopPrice.toString(),
            TvTableTheme.tvRed,
            Icons.arrow_downward_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TvTableTheme.tvCardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TvTableTheme.tvBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradingsTable(dynamic res) {
    if (res.tradings.isEmpty) {
      return const Center(
        child: Text(
          '无仓位交易计划数据',
          style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 13),
        ),
      );
    }

    return Container(
      color: TvTableTheme.tvCanvasBg,
      margin: const EdgeInsets.only(top: 8),
      child: TvTableTheme.buildStickyTable(
        firstColumn: const DataColumn(label: Text('LEVEL', style: TvTableTheme.headerTextStyle)),
        remainingColumns: const [
          DataColumn(label: Text('BUY PRICE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('SELL PRICE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('BUY QTY', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('AVG ENTRY PRICE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('AVG ENTRY QTY', style: TvTableTheme.headerTextStyle)),
        ],
        itemCount: res.tradings.length,
        firstCellBuilder: (index) {
          return DataCell(
            Text(
              'L${index + 1}',
              style: const TextStyle(
                color: TvTableTheme.tvCyan,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
        },
        remainingCellsBuilder: (index) {
          final item = res.tradings[index];
          return [
            DataCell(
              Text(
<<<<<<< Updated upstream
                item.buyPrice.toStringAsFixed(4),
=======
                item.buyPrice.toString(),
>>>>>>> Stashed changes
                style: const TextStyle(
                  color: TvTableTheme.tvGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            DataCell(
              Text(
<<<<<<< Updated upstream
                item.sellPrice.toStringAsFixed(4),
=======
                item.sellPrice.toString(),
>>>>>>> Stashed changes
                style: const TextStyle(
                  color: TvTableTheme.tvRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
<<<<<<< Updated upstream
            DataCell(Text(item.quantity.toStringAsFixed(4), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.entryPrice.toStringAsFixed(4), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.entryQuantity.toStringAsFixed(4), style: TvTableTheme.numberTextStyle)),
=======
            DataCell(Text(item.quantity.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.entryPrice.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.entryQuantity.toString(), style: TvTableTheme.numberTextStyle)),
>>>>>>> Stashed changes
          ];
        },
      ),
    );
  }
}
