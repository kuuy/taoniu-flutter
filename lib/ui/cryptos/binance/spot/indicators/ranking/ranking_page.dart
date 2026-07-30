import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        return 'PROFIT TARGET';
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

  Widget _buildRankingTable(List<String> items) {
    return Container(
      color: TvTableTheme.tvCanvasBg,
      child: TvTableTheme.buildStickyTable(
        firstColumn: const DataColumn(label: Text('SYMBOL', style: TvTableTheme.headerTextStyle)),
        remainingColumns: controller.fields
            .map((f) => DataColumn(
                  label: Text(_formatHeader(f), style: TvTableTheme.headerTextStyle),
                ))
            .toList(),
        itemCount: items.length,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: _buildAppBar(context),
      body: ScrollConfiguration(
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
              final data = controller.rankingData[interval] ?? [];
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
                    'No data available',
                    style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 14),
                  ),
                );
              }

              return _buildRankingTable(data);
            });
          },
        ),
      ),
    );
  }
}
