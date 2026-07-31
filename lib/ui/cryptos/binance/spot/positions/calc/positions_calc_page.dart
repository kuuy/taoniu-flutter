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
      appBar: TvTableTheme.buildAppBar(
        title: 'Positions Calc (Binance Spot)',
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
                child: TextField(
                  controller: controller.maxCapitalController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Max Capital',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: TvTableTheme.tvCyan, size: 16),
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
                    labelText: 'Entry Price',
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
                    labelText: 'Entry Qty',
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
    final rrRatio = controller.riskRewardRatio;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Row(
        children: [
          _buildSummaryCard(
            '止盈目标 (Take Price)',
            res.takePrice.toString(),
            tpPct != null ? '+${tpPct.toStringAsFixed(2)}%' : null,
            TvTableTheme.tvGreen,
            Icons.arrow_upward_rounded,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            '止损触发 (Stop Price)',
            res.stopPrice.toString(),
            slPct != null ? '${slPct.toStringAsFixed(2)}%' : null,
            TvTableTheme.tvRed,
            Icons.arrow_downward_rounded,
          ),
          if (rrRatio != null) ...[
            const SizedBox(width: 8),
            _buildSummaryCard(
              '盈亏比 (R:R Ratio)',
              '1 : ${rrRatio.toStringAsFixed(2)}',
              null,
              TvTableTheme.tvAmber,
              Icons.balance_rounded,
            ),
          ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
          Icon(Icons.analytics_outlined, color: TvTableTheme.tvTextSecondary.withValues(alpha: 0.4), size: 48),
          const SizedBox(height: 12),
          const Text(
            '暂无持仓计算数据',
            style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            '请检查并填写 Symbol、最大资金及建仓价格后点击“计算”',
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

  Widget _buildTradingsTable(dynamic res) {
    if (res.tradings.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            color: TvTableTheme.tvCanvasBg,
            margin: const EdgeInsets.only(top: 6),
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
                      item.buyPrice.toString(),
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
                      item.sellPrice.toString(),
                      style: const TextStyle(
                        color: TvTableTheme.tvRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  DataCell(Text(item.quantity.toString(), style: TvTableTheme.numberTextStyle)),
                  DataCell(Text(item.entryPrice.toString(), style: TvTableTheme.numberTextStyle)),
                  DataCell(Text(item.entryQuantity.toString(), style: TvTableTheme.numberTextStyle)),
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
            '共 ${res.tradings.length} 层补仓计划',
            style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11.5),
          ),
          Obx(() {
            final sym = controller.currentSymbol.value;
            return Text(
              'Symbol: $sym',
              style: const TextStyle(color: TvTableTheme.tvCyan, fontSize: 11.5, fontWeight: FontWeight.bold),
            );
          }),
        ],
      ),
    );
  }
}

