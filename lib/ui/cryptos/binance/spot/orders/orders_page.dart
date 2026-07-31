import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/order.dart';
import 'package:taoniu/routes/app_routes.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'orders_controller.dart';

class OrdersPage extends GetView<OrdersController> {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(
        title: 'Binance Spot 订单管理',
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.isTableView.value ? Icons.view_agenda_outlined : Icons.table_chart_outlined,
                  color: TvTableTheme.tvTextPrimary,
                  size: 20,
                ),
                tooltip: controller.isTableView.value ? '切换卡片视图' : '切换表格视图',
                onPressed: () => controller.toggleViewMode(),
              )),
          IconButton(
            icon: const Icon(Icons.refresh, color: TvTableTheme.tvTextPrimary, size: 20),
            tooltip: '刷新',
            onPressed: () => controller.fetchOrders(isRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildSearchBar(),
          const Divider(height: 1, color: TvTableTheme.tvBorderColor),

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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_late_outlined, color: TvTableTheme.tvTextSecondary.withValues(alpha: 0.4), size: 48),
                      const SizedBox(height: 12),
                      Text(
                        '暂无匹配的订单记录 (${controller.selectedSymbol.value})',
                        style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: TvTableTheme.tvBlue,
                backgroundColor: TvTableTheme.tvHeaderBg,
                onRefresh: () async => controller.fetchOrders(isRefresh: true),
                child: controller.isTableView.value
                    ? _buildTableView(context, displayItems)
                    : _buildCardView(context, displayItems),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: TvTableTheme.tvHeaderBg,
      child: Column(
        children: [
          // Symbol Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('标的: ', style: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 11.5)),
                ...controller.symbols.map((symbol) {
                  return Obx(() {
                    final isSelected = controller.selectedSymbol.value == symbol;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(symbol),
                        visualDensity: VisualDensity.compact,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : TvTableTheme.tvTextSecondary,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: TvTableTheme.tvCanvasBg,
                        selectedColor: TvTableTheme.tvBlue,
                        side: BorderSide(
                          color: isSelected ? TvTableTheme.tvBlue : TvTableTheme.tvBorderColor,
                        ),
                        onSelected: (_) => controller.changeSymbol(symbol),
                      ),
                    );
                  });
                }),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Side Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('方向: ', style: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 11.5)),
                ...controller.sides.map((side) {
                  return Obx(() {
                    final isSelected = controller.selectedSide.value == side;
                    Color sideColor = TvTableTheme.tvBlue;
                    if (side == 'BUY') sideColor = TvTableTheme.tvGreen;
                    if (side == 'SELL') sideColor = TvTableTheme.tvRed;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(side),
                        visualDensity: VisualDensity.compact,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : TvTableTheme.tvTextSecondary,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: TvTableTheme.tvCanvasBg,
                        selectedColor: sideColor,
                        side: BorderSide(
                          color: isSelected ? sideColor : TvTableTheme.tvBorderColor,
                        ),
                        onSelected: (_) => controller.changeSide(side),
                      ),
                    );
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: TvTableTheme.tvHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SizedBox(
        height: 36,
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontSize: 12.5,
            color: TvTableTheme.tvTextPrimary,
          ),
          strutStyle: const StrutStyle(
            fontSize: 12.5,
            height: 1.0,
            leading: 0,
            forceStrutHeight: true,
          ),
          decoration: InputDecoration(
            hintText: '搜索订单标的 (如 BTC, ETH, SOL...)',
            hintStyle: const TextStyle(
              color: TvTableTheme.tvTextSecondary,
              fontSize: 12,
            ),
            prefixIcon: const Icon(Icons.search, color: TvTableTheme.tvTextSecondary, size: 18),
            prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 36),
            suffixIcon: Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: TvTableTheme.tvTextSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                  onPressed: () => controller.searchQuery.value = '',
                );
              }
              return const SizedBox.shrink();
            }),
            suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 36),
            filled: true,
            fillColor: TvTableTheme.tvCanvasBg,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TvTableTheme.tvBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TvTableTheme.tvBlue),
            ),
          ),
          onChanged: (val) => controller.searchQuery.value = val,
        ),
      ),
    );
  }

  Widget _buildTableView(BuildContext context, List<Order> displayItems) {
    return Container(
      color: TvTableTheme.tvCanvasBg,
      child: TvTableTheme.buildStickyTable(
        firstColumn: const DataColumn(label: Text('SYMBOL', style: TvTableTheme.headerTextStyle)),
        remainingColumns: const [
          DataColumn(label: Text('ORDER ID', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('TYPE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('SIDE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('PRICE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('QUANTITY', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('AMOUNT', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('OPEN TIME', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('UPDATE TIME', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('STATUS', style: TvTableTheme.headerTextStyle)),
        ],
        itemCount: displayItems.length,
        onSelectRow: (index) => _showOrderActionSheet(context, displayItems[index]),
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
          final isBuy = item.isBuy;

          return [
            DataCell(Text(item.orderId.toString(), style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11.5))),
            DataCell(Text(item.type.isEmpty ? 'LIMIT' : item.type, style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12))),
            DataCell(
              Text(
                isBuy ? 'BUY' : 'SELL',
                style: TextStyle(
                  color: isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataCell(Text(item.price.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.quantity.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.amount > 0 ? item.amount.toStringAsFixed(4) : '-', style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.formatTime(item.openTime), style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11.5))),
            DataCell(Text(item.formatTime(item.updateTime), style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11.5))),
            DataCell(Text(item.statusText, style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12))),
          ];
        },
      ),
    );
  }

  Widget _buildCardView(BuildContext context, List<Order> displayItems) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        final isBuy = item.isBuy;

        return Card(
          color: TvTableTheme.tvCardBg,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: TvTableTheme.tvBorderColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _showOrderActionSheet(context, item),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.symbol,
                            style: const TextStyle(
                              color: TvTableTheme.tvTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isBuy ? 'BUY' : 'SELL',
                              style: TextStyle(
                                color: isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right_rounded, color: TvTableTheme.tvTextHeader, size: 20),
                    ],
                  ),
                  const Divider(height: 14, color: TvTableTheme.tvBorderColor),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardStatItem('委托价格 (Price)', item.price.toString(), isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed),
                      ),
                      Expanded(
                        child: _buildCardStatItem('委托数量 (Qty)', item.quantity.toString(), TvTableTheme.tvTextPrimary),
                      ),
                      Expanded(
                        child: _buildCardStatItem('类型 (Type)', item.type.isEmpty ? 'LIMIT' : item.type, TvTableTheme.tvCyan),
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

  Widget _buildCardStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: TvTableTheme.tvTextHeader,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  void _showOrderActionSheet(BuildContext context, Order item) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.symbol,
                  style: const TextStyle(
                    color: TvTableTheme.tvTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '委托价: \$${item.price}',
                  style: const TextStyle(color: TvTableTheme.tvCyan, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.exposure_rounded, color: TvTableTheme.tvBlue),
              title: const Text('带入 Symbol 与委托价至 Positions Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotPositionsCalc,
                  arguments: {
                    'symbol': item.symbol,
                    'entryPrice': item.price,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate_rounded, color: TvTableTheme.tvCyan),
              title: const Text('带入 Symbol 与委托价至 Gambling Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotGamblingCalc,
                  arguments: {
                    'symbol': item.symbol,
                    'entryPrice': item.price,
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
