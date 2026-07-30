import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/binance/spot/plan.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'plans_controller.dart';

class PlansPage extends GetView<BinanceSpotPlansController> {
  const PlansPage({super.key});

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: TvTableTheme.tvHeaderBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: TvTableTheme.tvTextPrimary),
      titleSpacing: 8.0,
      title: Row(
        children: [
          const Text(
            'Plans',
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

  Widget _buildTable(List<Plan> items) {
    return Container(
      color: TvTableTheme.tvCanvasBg,
      child: TvTableTheme.buildStickyTable(
        firstColumn: const DataColumn(label: Text('SYMBOL', style: TvTableTheme.headerTextStyle)),
        remainingColumns: const [
          DataColumn(label: Text('SIDE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('PRICE', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('QUANTITY', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('AMOUNT', style: TvTableTheme.headerTextStyle)),
          DataColumn(label: Text('STATUS', style: TvTableTheme.headerTextStyle)),
        ],
        itemCount: items.length,
        firstCellBuilder: (index) {
          final item = items[index];
          return DataCell(Text(item.symbol, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontWeight: FontWeight.w600, fontSize: 12.5, letterSpacing: 0.3)));
        },
        remainingCellsBuilder: (index) {
          final item = items[index];
          final isBuy = item.side == 1 || item.side.toString().toUpperCase() == 'BUY';
          return [
            DataCell(
              Text(
                item.side.toString(),
                style: TextStyle(
                  color: isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataCell(Text(item.price.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.quantity.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.amount.toString(), style: TvTableTheme.numberTextStyle)),
            DataCell(Text(item.status.toString(), style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12))),
          ];
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
              final data = controller.plansData[interval] ?? [];
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

              return _buildTable(data);
            });
          },
        ),
      ),
    );
  }
}
