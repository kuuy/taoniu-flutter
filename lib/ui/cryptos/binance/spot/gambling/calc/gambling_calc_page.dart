import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'gambling_calc_controller.dart';

class GamblingCalcPage extends GetView<GamblingCalcController> {
  const GamblingCalcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(title: 'Gambling Calc (Binance Spot)'),
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
                    child: _buildPlansTable(res),
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
                flex: 3,
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
                flex: 2,
                child: Obx(() => Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: TvTableTheme.tvCanvasBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: TvTableTheme.tvBorderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.selectedSide.value = 1,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: controller.selectedSide.value == 1
                                      ? TvTableTheme.tvGreen.withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'BUY (多)',
                                  style: TextStyle(
                                    color: controller.selectedSide.value == 1
                                        ? TvTableTheme.tvGreen
                                        : TvTableTheme.tvTextSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.selectedSide.value = 2,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: controller.selectedSide.value == 2
                                      ? TvTableTheme.tvRed.withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'SELL (空)',
                                  style: TextStyle(
                                    color: controller.selectedSide.value == 2
                                        ? TvTableTheme.tvRed
                                        : TvTableTheme.tvTextSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
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
                    labelText: 'Entry Price (可选)',
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
                    labelText: 'Entry Qty (可选)',
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
            '止盈目标价',
<<<<<<< Updated upstream
            res.takePrice.toStringAsFixed(4),
=======
            res.takePrice.toString(),
>>>>>>> Stashed changes
            TvTableTheme.tvGreen,
            Icons.arrow_upward_rounded,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            '止损触发价',
<<<<<<< Updated upstream
            res.stopPrice.toStringAsFixed(4),
=======
            res.stopPrice.toString(),
>>>>>>> Stashed changes
            TvTableTheme.tvRed,
            Icons.arrow_downward_rounded,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            '计划预估收益',
<<<<<<< Updated upstream
            res.planProfit.toStringAsFixed(4),
=======
            res.planProfit.toString(),
>>>>>>> Stashed changes
            TvTableTheme.tvAmber,
            Icons.account_balance_wallet_outlined,
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
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansTable(dynamic res) {
    if (res.plans.isEmpty) {
      return const Center(
        child: Text(
          '无分步计算计划',
          style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 13),
        ),
      );
    }

    return Container(
      color: TvTableTheme.tvCanvasBg,
      margin: const EdgeInsets.only(top: 8),
      child: TvTableTheme.buildStickyTable(
        firstColumn: const DataColumn(label: Text('STEP', style: TvTableTheme.headerTextStyle)),
        remainingColumns: const [
          DataColumn(label: Text('TAKE PRICE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('TAKE QTY', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('TAKE PROFIT', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('AMOUNT', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('ACCUM PROFIT', style: TvTableTheme.headerTextStyle)),
        ],
        itemCount: res.plans.length,
        firstCellBuilder: (index) {
          return DataCell(
            Text(
              '#${index + 1}',
              style: const TextStyle(
                color: TvTableTheme.tvBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
        },
        remainingCellsBuilder: (index) {
          final plan = res.plans[index];
          return [
<<<<<<< Updated upstream
            DataCell(Text(plan.price.toStringAsFixed(4), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(plan.quantity.toStringAsFixed(4), style: TvTableTheme.numberTextStyle)),
            DataCell(
              Text(
                plan.takeProfit.toStringAsFixed(4),
=======
            DataCell(Text(plan.price.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(plan.quantity.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(
              Text(
                plan.takeProfit.toString(),
>>>>>>> Stashed changes
                style: TextStyle(
                  color: plan.takeProfit >= 0 ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 12,
                ),
              ),
            ),
<<<<<<< Updated upstream
            DataCell(Text(plan.amount.toStringAsFixed(4), style: TvTableTheme.numberTextStyle)),
            DataCell(
              Text(
                plan.profit.toStringAsFixed(4),
=======
            DataCell(Text(plan.amount.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(
              Text(
                plan.profit.toString(),
>>>>>>> Stashed changes
                style: TextStyle(
                  color: plan.profit >= 0 ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 12,
                ),
              ),
            ),
          ];
        },
      ),
    );
  }
}
