import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/spot_ticker.dart';
import 'package:taoniu/routes/app_routes.dart';
import 'package:taoniu/ui/components/pulsing_badge.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'ranking_controller.dart';

class IndicatorSignalInfo {
  final String label;
  final Color color;
  final String zone;

  const IndicatorSignalInfo({
    required this.label,
    required this.color,
    required this.zone,
  });

  static IndicatorSignalInfo evaluateAhr999(double? val) {
    if (val == null) return const IndicatorSignalInfo(label: '未获取', color: TvTableTheme.tvTextSecondary, zone: '数据未就绪');
    if (val < 0.45) return const IndicatorSignalInfo(label: '抄底买入', color: TvTableTheme.tvGreen, zone: '抄底区间 (< 0.45)');
    if (val < 1.2) return const IndicatorSignalInfo(label: '定投建仓', color: TvTableTheme.tvCyan, zone: '定投区间 (0.45 ~ 1.2)');
    if (val < 5.0) return const IndicatorSignalInfo(label: '牛市持仓', color: TvTableTheme.tvAmber, zone: '牛市区间 (1.2 ~ 5.0)');
    return const IndicatorSignalInfo(label: '狂热止盈', color: TvTableTheme.tvRed, zone: '逃顶区间 (>= 5.0)');
  }

  static IndicatorSignalInfo evaluateMvrv(double? val) {
    if (val == null) return const IndicatorSignalInfo(label: '未获取', color: TvTableTheme.tvTextSecondary, zone: '数据未就绪');
    if (val < 1.0) return const IndicatorSignalInfo(label: '极度低估', color: TvTableTheme.tvGreen, zone: '探底区 (< 1.0)');
    if (val < 2.0) return const IndicatorSignalInfo(label: '温和蓄势', color: TvTableTheme.tvCyan, zone: '积累区 (1.0 ~ 2.0)');
    if (val < 3.5) return const IndicatorSignalInfo(label: '阶段偏高', color: TvTableTheme.tvAmber, zone: '减仓区 (2.0 ~ 3.5)');
    return const IndicatorSignalInfo(label: '极度过热', color: TvTableTheme.tvRed, zone: '顶部狂热 (>= 3.5)');
  }

  static ({String title, String desc, Color color, String badge}) evaluateCombined(double? ahr, double? mv) {
    if (ahr == null && mv == null) {
      return (
        title: 'BTC 1D 多空指标加载中',
        desc: '通过 IndicatorsApi 获取 BTCUSDT 1d 周期 ahr999 及 mvrv...',
        color: TvTableTheme.tvTextSecondary,
        badge: 'LOADING',
      );
    }
    final a = ahr ?? 1.0;
    final m = mv ?? 1.5;

    if (a < 0.45 && m < 1.0) {
      return (
        title: '强力做多 / 黄金抄底区',
        desc: 'BTC 1d ahr999与MVRV均处于历史极度低估区间，极高盈亏比抄底/做多窗口',
        color: TvTableTheme.tvGreen,
        badge: 'STRONG LONG',
      );
    } else if (a < 1.2 && m < 2.0) {
      return (
        title: '定投建仓 / 多头蓄势区',
        desc: '指标处于筹码估值合理区间，适合逢低分批定投建仓或持有多单',
        color: TvTableTheme.tvCyan,
        badge: 'DCA / BUY',
      );
    } else if (a >= 5.0 || m >= 3.5) {
      return (
        title: '极度狂热 / 强烈看空止盈',
        desc: '市场进入牛市顶部过热高风险区，建议分批平多止盈或对冲做空',
        color: TvTableTheme.tvRed,
        badge: 'STRONG SHORT',
      );
    } else if (m >= 2.5 || a >= 2.0) {
      return (
        title: '阶段高位 / 防守避险',
        desc: '市场筹码获利盘较高，建议上移止损防守，警惕回调风险',
        color: TvTableTheme.tvAmber,
        badge: 'NEUTRAL / DEFENSE',
      );
    } else {
      return (
        title: '中性持仓 / 趋势跟踪',
        desc: '指标处于常态市场区间，保持原有策略，顺应趋势交易',
        color: TvTableTheme.tvBlue,
        badge: 'HOLD / NEUTRAL',
      );
    }
  }
}

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
      case 'change':
        return 'CHANGE%';
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

    if (field == 'change' || field.contains('change')) {
      // Ranking API returns change as a decimal ratio (e.g. 0.0245 = 2.45%),
      // convert to percentage scale (* 100) to align with Realtime Tickers.
      final changePercent = numVal.abs() <= 1.0 ? numVal * 100 : numVal;
      final normVal = SpotTicker.normalizeChangePercent(changePercent);
      final isPositive = normVal > 0;
      final isZero = normVal.abs() < 0.0001;
      final Color textColor = isZero
          ? TvTableTheme.tvTextSecondary
          : isPositive
              ? TvTableTheme.tvGreen
              : TvTableTheme.tvRed;
      final sign = isPositive ? '+' : '';
      final displayStr = '$sign${normVal.toStringAsFixed(2)}%';

      return Text(
        displayStr,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    } else if (field.contains('ratio')) {
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

  Widget _buildBtc1dCard(BuildContext context) {
    return Obx(() {
      if (controller.selectedInterval.value != '1d') {
        return const SizedBox.shrink();
      }

      final ahr999 = controller.btcAhr999.value;
      final mvrv = controller.btcMvrv.value;
      final price = controller.btcPrice.value;

      final ahrInfo = IndicatorSignalInfo.evaluateAhr999(ahr999);
      final mvrvInfo = IndicatorSignalInfo.evaluateMvrv(mvrv);
      final combined = IndicatorSignalInfo.evaluateCombined(ahr999, mvrv);

      final priceText = price != null ? ' (现价 $price)' : '';

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TvTableTheme.tvHeaderBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TvTableTheme.tvBorderColor, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_rounded, color: TvTableTheme.tvBlue, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'BTCUSDT 1D 指标多空信号$priceText',
                      style: const TextStyle(
                        color: TvTableTheme.tvTextPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PulsingBadge(
                  label: combined.badge,
                  color: combined.color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: combined.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: combined.color.withValues(alpha: 0.25), width: 0.8),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded, color: combined.color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          combined.title,
                          style: TextStyle(
                            color: combined.color,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          combined.desc,
                          style: const TextStyle(
                            color: TvTableTheme.tvTextSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: TvTableTheme.tvCanvasBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ahr999',
                          style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11.5),
                        ),
                        Text(
                          ahr999 != null ? '${ahr999.toStringAsFixed(ahr999.abs() >= 10 ? 2 : 4)} (${ahrInfo.label})' : '未获取',
                          style: TextStyle(
                            color: ahrInfo.color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: TvTableTheme.tvCanvasBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'mvrv',
                          style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11.5),
                        ),
                        Text(
                          mvrv != null ? '${mvrv.toStringAsFixed(mvrv.abs() >= 10 ? 2 : 4)} (${mvrvInfo.label})' : '未获取',
                          style: TextStyle(
                            color: mvrvInfo.color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
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
              leading: const Icon(Icons.candlestick_chart_rounded, color: TvTableTheme.tvGreen),
              title: const Text('查看 TradingView K 线图表', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotTradings,
                  arguments: {
                    'symbol': symbol,
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
          _buildBtc1dCard(context),
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, color: TvTableTheme.tvTextSecondary, size: 40),
                            const SizedBox(height: 8),
                            const Text(
                              '暂无匹配指标数据',
                              style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 13.5),
                            ),
                            if (controller.searchQuery.value.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: TvTableTheme.tvBlue, width: 0.8),
                                  foregroundColor: TvTableTheme.tvBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.clear, size: 14),
                                label: const Text('清除搜索条件', style: TextStyle(fontSize: 12)),
                                onPressed: () => controller.clearSearch(),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: TvTableTheme.tvBlue,
                      backgroundColor: TvTableTheme.tvHeaderBg,
                      onRefresh: () async => controller.refreshData(),
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

