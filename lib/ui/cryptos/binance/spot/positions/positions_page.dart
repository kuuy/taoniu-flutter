import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/binance/spot/position.dart';
import 'package:taoniu/routes/app_routes.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'positions_controller.dart';

class PositionsPage extends GetView<PositionsController> {
  const PositionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(
        title: 'Positions (Binance Spot)',
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.isTableView.value ? Icons.grid_view_rounded : Icons.table_chart_rounded,
                  color: TvTableTheme.tvTextSecondary,
                  size: 20,
                ),
                tooltip: controller.isTableView.value ? '切换卡片视图' : '切换表格视图',
                onPressed: controller.toggleViewMode,
              )),
          IconButton(
            icon: const Icon(Icons.calculate_rounded, color: TvTableTheme.tvCyan, size: 20),
            tooltip: 'Gambling Calc',
            onPressed: () => Get.toNamed(AppRoutes.binanceSpotGamblingCalc),
          ),
          IconButton(
            icon: const Icon(Icons.exposure_rounded, color: TvTableTheme.tvBlue, size: 20),
            tooltip: 'Positions Calc',
            onPressed: () => Get.toNamed(AppRoutes.binanceSpotPositionsCalc),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: TvTableTheme.tvGreen,
        backgroundColor: TvTableTheme.tvHeaderBg,
        onRefresh: () => controller.fetchPositions(isRefresh: true),
        child: Column(
          children: [
            _buildHeaderSummary(),
            _buildSearchBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(TvTableTheme.tvGreen),
                    ),
                  );
                }

                final displayItems = controller.filteredItems;
                if (displayItems.isEmpty) {
                  return _buildEmptyState();
                }

                return controller.isTableView.value
                    ? _buildTableView(context, displayItems)
                    : _buildCardView(context, displayItems);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSummary() {
    return Obx(() {
      final totalCap = controller.totalCapital;
      final totalNot = controller.totalNotional;
      final totalCount = controller.items.length;
      final longCount = controller.longCount;
      final shortCount = controller.shortCount;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 4),
        decoration: BoxDecoration(
          color: TvTableTheme.tvHeaderBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TvTableTheme.tvBorderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryTile(
                '持仓笔数',
                '$totalCount 笔',
                '多: $longCount / 空: $shortCount',
                TvTableTheme.tvCyan,
                Icons.analytics_rounded,
              ),
            ),
            Container(width: 1, height: 32, color: TvTableTheme.tvBorderColor),
            Expanded(
              child: _buildSummaryTile(
                '总保证金 (Capital)',
                totalCap.toStringAsFixed(2),
                'USDT',
                TvTableTheme.tvGreen,
                Icons.account_balance_wallet_outlined,
              ),
            ),
            Container(width: 1, height: 32, color: TvTableTheme.tvBorderColor),
            Expanded(
              child: _buildSummaryTile(
                '总名义头寸 (Notional)',
                totalNot.toStringAsFixed(2),
                'USDT',
                TvTableTheme.tvPurple,
                Icons.show_chart_rounded,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryTile(String label, String value, String subtitle, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 10.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: const TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 12.5),
        decoration: InputDecoration(
          hintText: '搜索持仓交易对 (Symbol)...',
          hintStyle: const TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: TvTableTheme.tvTextHeader, size: 18),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: TvTableTheme.tvTextSecondary, size: 16),
                  onPressed: () => controller.searchQuery.value = '',
                )
              : const SizedBox.shrink()),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          fillColor: TvTableTheme.tvHeaderBg,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: TvTableTheme.tvBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: TvTableTheme.tvBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(Get.context!).size.height * 0.15),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, color: TvTableTheme.tvTextSecondary.withValues(alpha: 0.4), size: 52),
              const SizedBox(height: 12),
              const Text(
                '暂无满足条件的持仓数据',
                style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                '下拉可刷新获取最新持仓行情',
                style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => controller.fetchPositions(isRefresh: true),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('刷新列表'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TvTableTheme.tvBlue,
                  side: const BorderSide(color: TvTableTheme.tvBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableView(BuildContext context, List<Position> displayItems) {
    return Container(
      color: TvTableTheme.tvCanvasBg,
      child: TvTableTheme.buildStickyTable(
        firstColumn: const DataColumn(label: Text('SYMBOL', style: TvTableTheme.headerTextStyle)),
        remainingColumns: const [
          DataColumn(label: Text('ENTRY PRICE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('ENTRY QTY', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('ENTRY AMOUNT', style: TvTableTheme.headerTextStyle)),
        ],
        itemCount: displayItems.length,
        onSelectRow: (index) => _showPositionActionSheet(context, displayItems[index]),
        firstCellBuilder: (index) {
          final item = displayItems[index];
          return DataCell(
            Text(
              item.symbol,
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
          final item = displayItems[index];
          return [
            DataCell(Text(item.entryPrice.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.entryQuantity.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.entryAmount.toString(), style: TvTableTheme.numberTextStyle)),
          ];
        },
      ),
    );
  }

  Widget _buildCardView(BuildContext context, List<Position> displayItems) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];

        return Card(
          color: TvTableTheme.tvCardBg,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: TvTableTheme.tvBorderColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _showPositionActionSheet(context, item),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.symbol,
                        style: const TextStyle(
                          color: TvTableTheme.tvTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: TvTableTheme.tvTextHeader, size: 20),
                    ],
                  ),
                  const Divider(height: 14, color: TvTableTheme.tvBorderColor),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardStatItem('建仓价格 (Entry Price)', item.entryPrice.toString(), TvTableTheme.tvGreen),
                      ),
                      Expanded(
                        child: _buildCardStatItem('建仓数量 (Entry Qty)', item.entryQuantity.toString(), TvTableTheme.tvTextPrimary),
                      ),
                      Expanded(
                        child: _buildCardStatItem('建仓金额 (Entry Amount)', item.entryAmount.toString(), TvTableTheme.tvCyan),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  void _showPositionActionSheet(BuildContext context, Position item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: TvTableTheme.tvHeaderBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: TvTableTheme.tvBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  item.symbol,
                  style: const TextStyle(
                    color: TvTableTheme.tvTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Entry: ${item.entryPrice} | Qty: ${item.entryQuantity}',
                  style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.exposure_rounded, color: TvTableTheme.tvBlue),
              title: const Text('带入参数至 Positions Calc (仓位计算)', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              subtitle: const Text('快速计算此持仓的补仓点位与止盈止损', style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotPositionsCalc,
                  arguments: {
                    'symbol': item.symbol,
                    'entryPrice': item.entryPrice,
                    'entryQuantity': item.entryQuantity,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate_rounded, color: TvTableTheme.tvCyan),
              title: const Text('带入参数至 Gambling Calc (Gambling 计算)', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              subtitle: const Text('生成此持仓的分步阶梯止盈计划', style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotGamblingCalc,
                  arguments: {
                    'symbol': item.symbol,
                    'side': item.side,
                    'entryPrice': item.entryPrice,
                    'entryQuantity': item.entryQuantity,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: TvTableTheme.tvAmber),
              title: const Text('复制 Symbol 名称', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.symbol));
                Get.back();
                Get.snackbar('成功', '已复制 ${item.symbol} 到剪贴板', duration: const Duration(seconds: 2));
              },
            ),
          ],
        ),
      ),
    );
  }
}

