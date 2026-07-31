import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taoniu/routes/app_routes.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'ranking_controller.dart';

class TickersRankingPage extends GetView<TickersRankingController> {
  const TickersRankingPage({super.key});

  String _formatHeader(String field) {
    switch (field) {
      case 'price':
        return 'PRICE';
      case 'open':
        return 'OPEN';
      case 'high':
        return 'HIGH';
      case 'low':
        return 'LOW';
      case 'volume':
        return 'VOLUME';
      case 'quota':
        return 'QUOTA';
      case 'change':
        return 'CHANGE%';
      case 'slippage_percent@1%':
        return 'SLIP 1%';
      case 'slippage_percent@2%':
        return 'SLIP 2%';
      default:
        return field.replaceAll('_', ' ').toUpperCase();
    }
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
            hintText: '搜索行情标的 (如 BTC, ETH, SOL...)',
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

  void _showTickerActionSheet(BuildContext context, String symbol, String rawPrice) {
    final parsedPrice = double.tryParse(rawPrice);

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
                  symbol,
                  style: const TextStyle(
                    color: TvTableTheme.tvTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (parsedPrice != null && parsedPrice > 0)
                  Text(
                    '最新价: \$${parsedPrice.toStringAsFixed(4)}',
                    style: const TextStyle(color: TvTableTheme.tvCyan, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.exposure_rounded, color: TvTableTheme.tvBlue),
              title: const Text('带入 Symbol 与最新价至 Positions Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotPositionsCalc,
                  arguments: {
                    'symbol': symbol,
                    'entryPrice': parsedPrice ?? 0.0,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate_rounded, color: TvTableTheme.tvCyan),
              title: const Text('带入 Symbol 与最新价至 Gambling Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotGamblingCalc,
                  arguments: {
                    'symbol': symbol,
                    'entryPrice': parsedPrice ?? 0.0,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: TvTableTheme.tvAmber),
              title: const Text('复制 Symbol 名称', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: symbol));
                Get.back();
                Get.snackbar('成功', '已复制 $symbol 到剪贴板', duration: const Duration(seconds: 2));
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
      appBar: TvTableTheme.buildAppBar(title: 'Binance Spot 行情排行榜'),
      body: Column(
        children: [
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
                return const Center(
                  child: Text(
                    '暂无匹配的行情数据',
                    style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 14),
                  ),
                );
              }

              return RefreshIndicator(
                color: TvTableTheme.tvBlue,
                backgroundColor: TvTableTheme.tvHeaderBg,
                onRefresh: () async => controller.fetchRanking(isRefresh: true),
                child: Container(
                  color: TvTableTheme.tvCanvasBg,
                  child: TvTableTheme.buildStickyTable(
                    firstColumn: const DataColumn(
                      label: Text('SYMBOL', style: TvTableTheme.headerTextStyle),
                    ),
                    remainingColumns: controller.fields.asMap().entries.map((entry) {
                      final fIdx = entry.key;
                      final f = entry.value;
                      final isSort = controller.sortFieldIndex.value == fIdx;
                      final arrow = controller.sortAscending.value ? ' ⬆' : ' ⬇';

                      return DataColumn(
                        label: InkWell(
                          onTap: () => controller.toggleSort(fIdx),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '${_formatHeader(f)}${isSort ? arrow : ''}',
                              style: isSort
                                  ? TvTableTheme.headerTextStyle.copyWith(
                                      color: TvTableTheme.tvBlue,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : TvTableTheme.headerTextStyle,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    itemCount: displayItems.length,
                    onSelectRow: (index) {
                      final item = displayItems[index];
                      final values = item.split(',');
                      final symbol = values.isNotEmpty ? values[0] : '';
                      final price = values.length > 1 ? values[1] : '';
                      _showTickerActionSheet(context, symbol, price);
                    },
                    firstCellBuilder: (index) {
                      final item = displayItems[index];
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
                      final item = displayItems[index];
                      final values = item.split(',');
                      final fieldsValues = List.generate(
                        controller.fields.length,
                        (i) => (i + 1 < values.length) ? values[i + 1] : '',
                      );
                      return fieldsValues.asMap().entries.map((fEntry) {
                        final fIdx = fEntry.key;
                        final val = fEntry.value;
                        final fieldName = controller.fields[fIdx];
                        final numVal = double.tryParse(val);

                        if (numVal != null) {
                          Color col = TvTableTheme.tvTextSecondary;
                          if (fieldName == 'change') {
                            if (numVal > 0) col = TvTableTheme.tvGreen;
                            if (numVal < 0) col = TvTableTheme.tvRed;
                          } else if (val.contains('.')) {
                            if (numVal > 0 && fieldName.contains('change')) col = TvTableTheme.tvGreen;
                            if (numVal < 0 && fieldName.contains('change')) col = TvTableTheme.tvRed;
                          }
                          return DataCell(
                            Text(
                              fieldName == 'change' ? '${numVal > 0 ? "+" : ""}${numVal.toStringAsFixed(2)}%' : val,
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
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
