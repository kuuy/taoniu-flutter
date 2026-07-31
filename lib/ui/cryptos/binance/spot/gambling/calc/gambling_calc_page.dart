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
      appBar: TvTableTheme.buildAppBar(
        title: 'Gambling Calc (Binance Spot)',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: TvTableTheme.tvTextSecondary, size: 20),
            tooltip: '重置表单参数',
            onPressed: controller.resetFields,
          ),
        ],
      ),
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
                return _buildEmptyState();
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
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TvTableTheme.tvBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSymbolChips(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: controller.symbolController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Symbol',
                    prefixIcon: Icon(Icons.currency_bitcoin_rounded, color: TvTableTheme.tvAmber, size: 16),
                    labelStyle: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 12),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Obx(() => Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: TvTableTheme.tvCanvasBg,
                        borderRadius: BorderRadius.circular(6),
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
                                  borderRadius: BorderRadius.circular(5),
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
                                  borderRadius: BorderRadius.circular(5),
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
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Entry Price (可选)',
                    prefixIcon: Icon(Icons.attach_money_rounded, color: TvTableTheme.tvGreen, size: 16),
                    labelStyle: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 12),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.entryQuantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => controller.calculate(),
                  style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Entry Qty (可选)',
                    prefixIcon: Icon(Icons.format_list_numbered_rounded, color: TvTableTheme.tvPurple, size: 16),
                    labelStyle: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 12),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: TvTableTheme.tvBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: controller.calculate,
                icon: const Icon(Icons.calculate_outlined, size: 16),
                label: const Text('计算', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TvTableTheme.tvBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(70, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.presetSymbols.map((sym) {
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Obx(() {
              final isSelected = controller.currentSymbol.value == sym;
              return ChoiceChip(
                label: Text(
                  sym,
                  style: TextStyle(
                    color: isSelected ? Colors.white : TvTableTheme.tvTextSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: TvTableTheme.tvBlue,
                backgroundColor: TvTableTheme.tvCanvasBg,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? TvTableTheme.tvBlue : TvTableTheme.tvBorderColor,
                  ),
                ),
                onSelected: (_) => controller.selectSymbol(sym),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(dynamic res) {
    final tpPct = controller.takeProfitChangePercent;
    final slPct = controller.stopLossChangePercent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Row(
        children: [
          _buildSummaryCard(
            '止盈目标价',
            res.takePrice.toString(),
            tpPct != null ? '+${tpPct.toStringAsFixed(2)}%' : null,
            TvTableTheme.tvGreen,
            Icons.arrow_upward_rounded,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            '止损触发价',
            res.stopPrice.toString(),
            slPct != null ? '${slPct.toStringAsFixed(2)}%' : null,
            TvTableTheme.tvRed,
            Icons.arrow_downward_rounded,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            '计划预估收益',
            res.planProfit.toString(),
            null,
            TvTableTheme.tvAmber,
            Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String? badge, Color color, IconData icon) {
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
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 10.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.casino_outlined, color: TvTableTheme.tvTextSecondary.withValues(alpha: 0.4), size: 48),
          const SizedBox(height: 12),
          const Text(
            '暂无分步 Gambling 计划数据',
            style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            '请输入交易对名称及选择多/空方向，点击“计算”生成计划',
            style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: controller.calculate,
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('立即计算'),
            style: OutlinedButton.styleFrom(
              foregroundColor: TvTableTheme.tvBlue,
              side: const BorderSide(color: TvTableTheme.tvBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTable(dynamic res) {
    if (res.plans.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            color: TvTableTheme.tvCanvasBg,
            margin: const EdgeInsets.only(top: 6),
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
                  DataCell(Text(plan.price.toString(), style: TvTableTheme.numberTextStyle)),
                  DataCell(Text(plan.quantity.toString(), style: TvTableTheme.numberTextStyle)),
                  DataCell(
                    Text(
                      plan.takeProfit.toString(),
                      style: TextStyle(
                        color: plan.takeProfit >= 0 ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataCell(Text(plan.amount.toString(), style: TvTableTheme.numberTextStyle)),
                  DataCell(
                    Text(
                      plan.profit.toString(),
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
          ),
        ),
        _buildTableSummaryFooter(res),
      ],
    );
  }

  Widget _buildTableSummaryFooter(dynamic res) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        border: Border(top: BorderSide(color: TvTableTheme.tvBorderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '共 ${res.plans.length} 步分阶段止盈计划',
            style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11.5),
          ),
          Obx(() {
            final sym = controller.currentSymbol.value;
            final sideText = controller.selectedSide.value == 1 ? 'BUY (多)' : 'SELL (空)';
            final sideColor = controller.selectedSide.value == 1 ? TvTableTheme.tvGreen : TvTableTheme.tvRed;
            return Row(
              children: [
                Text(
                  '$sym  ',
                  style: const TextStyle(color: TvTableTheme.tvCyan, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: sideColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    sideText,
                    style: TextStyle(color: sideColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

