import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taoniu/routes/app_routes.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'ranking_controller.dart';

class IndicatorsRankingPage extends GetView<IndicatorsRankingController> {
  const IndicatorsRankingPage({super.key});

  String _formatHeader(String field) {
    switch (field) {
      case 'r1':
        return 'R1';
      case 's1':
        return 'S1';
      case 'poc':
        return 'POC';
      case 'vah':
        return 'VAH';
      case 'val':
        return 'VAL';
      case 'poc_ratio':
        return 'POC RATIO';
      case 'profit_target':
        return 'TARGET';
      case 'stop_loss_point':
        return 'STOP LOSS';
      case 'risk_reward_ratio':
        return 'R/R RATIO';
      case 'take_profit_ratio':
        return 'TP RATIO';
      default:
        return field.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildSymbolCell(String symbol) {
    return Text(
      symbol,
      style: const TextStyle(
        color: TvTableTheme.tvTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildCell(String field, String rawVal) {
    if (rawVal.isEmpty) {
      return const Text('-', style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12));
    }

    final numVal = double.tryParse(rawVal);
    if (numVal == null) {
      return Text(
        rawVal,
        style: const TextStyle(
          color: TvTableTheme.tvTextSecondary,
          fontSize: 12,
        ),
      );
    }

    Color textColor = TvTableTheme.tvTextSecondary;
    String displayVal = rawVal;

    if (field.contains('ratio')) {
      displayVal = numVal.toStringAsFixed(2);
      if (numVal > 0) {
        textColor = TvTableTheme.tvGreen;
      } else if (numVal < 0) {
        textColor = TvTableTheme.tvRed;
      }
    } else {
      if (numVal.abs() >= 1000) {
        displayVal = numVal.toStringAsFixed(2);
      } else if (numVal.abs() >= 1) {
        displayVal = numVal.toStringAsFixed(4);
      } else {
        displayVal = numVal.toStringAsFixed(6);
      }
    }

    return Text(
      displayVal,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: TvTableTheme.tvHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            hintText: '搜索指标标的 (如 BTC, ETH, SOL...)',
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: TvTableTheme.tvHeaderBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: TvTableTheme.tvTextPrimary),
      titleSpacing: 8.0,
      title: Row(
        children: [
          const Text(
            'Indicators Ranking',
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

  Widget _buildRankingTable(BuildContext context, List<String> items) {
    return Container(
      color: TvTableTheme.tvCanvasBg,
      child: Obx(() {
        return TvTableTheme.buildStickyTable(
          firstColumn: const DataColumn(label: Text('SYMBOL', style: TvTableTheme.headerTextStyle)),
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
          itemCount: items.length,
          onSelectRow: (index) {
            final item = items[index];
            final values = item.split(',');
            final symbol = values.isNotEmpty ? values[0] : '';
            final pocPrice = values.length > 3 ? values[3] : '';
            _showIndicatorActionSheet(context, symbol, pocPrice);
          },
          firstCellBuilder: (index) {
            final item = items[index];
            final values = item.split(',');
            final symbol = values.isNotEmpty ? values[0] : '';
            return DataCell(_buildSymbolCell(symbol));
          },
          remainingCellsBuilder: (index) {
            final item = items[index];
            final values = item.split(',');
            final fieldsValues = List.generate(
              controller.fields.length,
              (i) => (i + 1 < values.length) ? values[i + 1] : '',
            );
            return controller.fields.asMap().entries.map((fEntry) {
              final fIdx = fEntry.key;
              final field = fEntry.value;
              final rawVal = fieldsValues[fIdx];
              return DataCell(_buildCell(field, rawVal));
            }).toList();
          },
        );
      }),
    );
  }

  void _showIndicatorActionSheet(BuildContext context, String symbol, String rawPrice) {
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
                    'POC 准价: $parsedPrice',
                    style: const TextStyle(color: TvTableTheme.tvCyan, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.exposure_rounded, color: TvTableTheme.tvBlue),
              title: const Text('带入 Symbol 与 POC 准价至 Positions Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
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
              title: const Text('带入 Symbol 与 POC 准价至 Gambling Calc', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
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
      appBar: _buildAppBar(context),
      body: Column(
        children: [
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
                          '暂无匹配指标数据',
                          style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 14),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: TvTableTheme.tvBlue,
                      backgroundColor: TvTableTheme.tvHeaderBg,
                      onRefresh: () async => controller.fetchRanking(),
                      child: _buildRankingTable(context, data),
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
