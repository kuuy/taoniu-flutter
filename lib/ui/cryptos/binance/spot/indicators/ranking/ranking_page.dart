import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ranking_controller.dart';

class IndicatorsRankingPage extends GetView<IndicatorsRankingController> {
  const IndicatorsRankingPage({super.key});

  // TradingView dark theme palette
  static const Color tvCanvasBg = Color(0xFF131722);
  static const Color tvHeaderBg = Color(0xFF1E222D);
  static const Color tvRowAltBg = Color(0xFF181C27);
  static const Color tvBorderColor = Color(0xFF2A2E39);
  static const Color tvTextHeader = Color(0xFF90939E);
  static const Color tvTextPrimary = Color(0xFFF0F3FA);
  static const Color tvTextSecondary = Color(0xFFB2B5BE);
  static const Color tvGreen = Color(0xFF089981);
  static const Color tvRed = Color(0xFFF23645);
  static const Color tvBlue = Color(0xFF2962FF);

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
        color: tvTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildCell(String field, String rawVal) {
    if (rawVal.isEmpty) {
      return const Text('-', style: TextStyle(color: tvTextSecondary, fontSize: 12));
    }

    final numVal = double.tryParse(rawVal);
    if (numVal == null) {
      return Text(
        rawVal,
        style: const TextStyle(
          color: tvTextSecondary,
          fontSize: 12,
        ),
      );
    }

    Color textColor = tvTextSecondary;
    String displayVal = rawVal;

    if (field.contains('ratio')) {
      displayVal = numVal.toStringAsFixed(2);
      if (numVal > 0) {
        textColor = tvGreen;
      } else if (numVal < 0) {
        textColor = tvRed;
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
      backgroundColor: tvHeaderBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: tvTextPrimary),
      titleSpacing: 8.0,
      title: Row(
        children: [
          const Text(
            'Indicators Ranking',
            style: TextStyle(
              color: tvTextPrimary,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12.0),
          Container(
            height: 16.0,
            width: 1.0,
            color: tvBorderColor,
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
                            color: isSelected ? tvBlue : Colors.transparent,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            interval,
                            style: TextStyle(
                              color: isSelected ? Colors.white : tvTextHeader,
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
        child: Divider(height: 1.0, thickness: 1.0, color: tvBorderColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const headerTextStyle = TextStyle(
      color: tvTextHeader,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    return Scaffold(
      backgroundColor: tvCanvasBg,
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(tvGreen),
            ),
          );
        }

        if (controller.items.isEmpty) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: tvTextSecondary, fontSize: 14),
            ),
          );
        }

        return Container(
          color: tvCanvasBg,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed Left Sticky Column (Symbol)
                Container(
                  decoration: const BoxDecoration(
                    color: tvCanvasBg,
                    border: Border(
                      right: BorderSide(
                        color: tvBorderColor,
                        width: 1.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 0),
                      ),
                    ],
                  ),
                  child: DataTable(
                    headingRowHeight: 38.0,
                    dataRowMinHeight: 36.0,
                    dataRowMaxHeight: 36.0,
                    columnSpacing: 20.0,
                    horizontalMargin: 16.0,
                    headingRowColor: WidgetStateProperty.all(tvHeaderBg),
                    border: const TableBorder(
                      horizontalInside: BorderSide(
                        color: tvBorderColor,
                        width: 0.5,
                      ),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text('SYMBOL', style: headerTextStyle),
                      ),
                    ],
                    rows: controller.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final values = item.split(',');
                      final symbol = values.isNotEmpty ? values[0] : '';
                      return DataRow(
                        color: WidgetStateProperty.all(
                          index % 2 == 0 ? tvCanvasBg : tvRowAltBg,
                        ),
                        cells: [
                          DataCell(_buildSymbolCell(symbol)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                // Scrollable Right Columns (Indicator Fields)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final numFields = controller.fields.length;
                      const avgColWidth = 60.0;
                      const horizontalPadding = 32.0;
                      final totalColWidth = numFields * avgColWidth;
                      final extraSpace = constraints.maxWidth -
                          totalColWidth -
                          horizontalPadding;
                      final dynamicSpacing = (numFields > 1 && extraSpace > 0)
                          ? (extraSpace / (numFields - 1)).clamp(20.0, 100.0)
                          : 20.0;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            headingRowHeight: 38.0,
                            dataRowMinHeight: 36.0,
                            dataRowMaxHeight: 36.0,
                            columnSpacing: dynamicSpacing,
                            horizontalMargin: 16.0,
                            headingRowColor:
                                WidgetStateProperty.all(tvHeaderBg),
                            border: const TableBorder(
                              horizontalInside: BorderSide(
                                color: tvBorderColor,
                                width: 0.5,
                              ),
                            ),
                            columns: controller.fields
                                .map((f) => DataColumn(
                                      label: Text(
                                        _formatHeader(f),
                                        style: headerTextStyle,
                                      ),
                                    ))
                                .toList(),
                            rows: controller.items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final values = item.split(',');
                              final fieldsValues = List.generate(
                                controller.fields.length,
                                (i) => (i + 1 < values.length) ? values[i + 1] : '',
                              );
                              return DataRow(
                                color: WidgetStateProperty.all(
                                  index % 2 == 0 ? tvCanvasBg : tvRowAltBg,
                                ),
                                cells: controller.fields
                                    .asMap()
                                    .entries
                                    .map((fEntry) {
                                  final fIdx = fEntry.key;
                                  final field = fEntry.value;
                                  final rawVal = fieldsValues[fIdx];
                                  return DataCell(_buildCell(field, rawVal));
                                }).toList(),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
