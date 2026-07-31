import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/strategy.dart';
import 'package:taoniu/routes/app_routes.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'strategies_controller.dart';

class StrategiesPage extends GetView<StrategiesController> {
  const StrategiesPage({super.key});

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: TvTableTheme.tvHeaderBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: TvTableTheme.tvTextPrimary),
      titleSpacing: 8.0,
      title: Row(
        children: [
          const Text(
            'Binance Spot 策略看板',
            style: TextStyle(
              color: TvTableTheme.tvTextPrimary,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12.0),
          Container(
            height: 16.0,
            width: 1.0,
            color: TvTableTheme.tvBorderColor,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() {
                return Row(
                  children: controller.intervals.map((interval) {
                    final isSelected =
                        controller.selectedInterval.value == interval;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: InkWell(
                        onTap: () => controller.setInterval(interval),
                        borderRadius: BorderRadius.circular(6.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? TvTableTheme.tvBlue : Colors.transparent,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            interval,
                            style: TextStyle(
                              color: isSelected ? Colors.white : TvTableTheme.tvTextHeader,
                              fontSize: 13.0,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(height: 1.0, thickness: 1.0, color: TvTableTheme.tvBorderColor),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: TvTableTheme.tvHeaderBg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text('信号方向: ', style: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 11.5)),
            ...controller.signals.map((sig) {
              return Obx(() {
                final isSelected = controller.selectedSignal.value == sig;
                Color sigColor = TvTableTheme.tvBlue;
                if (sig == 'BUY') sigColor = TvTableTheme.tvGreen;
                if (sig == 'SELL') sigColor = TvTableTheme.tvRed;

                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(sig),
                    visualDensity: VisualDensity.compact,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : TvTableTheme.tvTextSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: TvTableTheme.tvCanvasBg,
                    selectedColor: sigColor,
                    side: BorderSide(
                      color: isSelected ? sigColor : TvTableTheme.tvBorderColor,
                    ),
                    onSelected: (_) => controller.changeSignal(sig),
                  ),
                );
              });
            }),
          ],
        ),
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
            hintText: '搜索策略标的 (如 BTC, ETH, SOL...)',
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

  Widget _buildTable(BuildContext context, List<Strategy> items) {
    return Container(
      color: TvTableTheme.tvCanvasBg,
      child: TvTableTheme.buildStickyTable(
        firstColumn: const DataColumn(label: Text('SYMBOL', style: TvTableTheme.headerTextStyle)),
        remainingColumns: const [
          DataColumn(label: Text('INDICATOR', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('SIGNAL', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('PRICE', style: TvTableTheme.headerTextStyle)),
        ],
        itemCount: items.length,
        onSelectRow: (index) => _showStrategyActionSheet(context, items[index]),
        firstCellBuilder: (index) {
          final item = items[index];
          return DataCell(Text(item.symbol, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontWeight: FontWeight.w600, fontSize: 12.5, letterSpacing: 0.3)));
        },
        remainingCellsBuilder: (index) {
          final item = items[index];
          final isBuy = item.isBuy;
          final isSell = item.isSell;
          final sigColor = isBuy
              ? TvTableTheme.tvGreen
              : (isSell ? TvTableTheme.tvRed : TvTableTheme.tvTextSecondary);
          return [
            DataCell(Text(item.indicator, style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12))),
            DataCell(
              Text(
                item.signalLabel,
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
  }

  void _showStrategyActionSheet(BuildContext context, Strategy item) {
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
                  '策略价: \$${item.price}',
                  style: const TextStyle(color: TvTableTheme.tvCyan, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.exposure_rounded, color: TvTableTheme.tvBlue),
              title: const Text('带入 Symbol 与策略价至 Positions Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
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
              title: const Text('带入 Symbol 与策略价至 Gambling Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildSearchBar(),
          const Divider(height: 1, color: TvTableTheme.tvBorderColor),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.intervals.length,
                itemBuilder: (context, index) {
                  final interval = controller.intervals[index];
                  return Obx(() {
                    final data = controller.getFilteredData(interval);
                    final isCurrentLoading = controller.isLoading.value &&
                        controller.selectedInterval.value == interval &&
                        data.isEmpty;

                    if (isCurrentLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(TvTableTheme.tvGreen),
                        ),
                      );
                    }

                    if (data.isEmpty) {
                      return const Center(
                        child: Text(
                          '暂无匹配策略数据',
                          style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 14),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: TvTableTheme.tvBlue,
                      backgroundColor: TvTableTheme.tvHeaderBg,
                      onRefresh: () async => controller.fetchStrategies(),
                      child: _buildTable(context, data),
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
