import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/klines_api.dart';
import 'package:taoniu/routes/app_routes.dart';
import 'package:taoniu/ui/components/charts/tradingview_chart.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'tradings_controller.dart';

class TradingsPage extends GetView<TradingsController> {
  const TradingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131722),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E222D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF0F3FA)),
        titleSpacing: 8.0,
        title: Obx(() => Row(
          children: [
            DropdownButton<String>(
              value: controller.selectedSymbol.value,
              dropdownColor: const Color(0xFF1E222D),
              style: const TextStyle(color: Color(0xFFF0F3FA), fontSize: 18, fontWeight: FontWeight.bold),
              underline: const SizedBox(),
              items: ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT'].map((symbol) {
                return DropdownMenuItem(
                  value: symbol,
                  child: Text(symbol),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.changeSymbol(value);
              },
            ),
            const SizedBox(width: 16),
            _buildIntervalChips(context),
          ],
        )),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.useTradingViewWidget.value ? Icons.auto_graph : Icons.candlestick_chart,
              color: controller.useTradingViewWidget.value ? const Color(0xFF2962FF) : Colors.white,
            ),
            tooltip: controller.useTradingViewWidget.value ? 'Lightweight Chart' : 'TradingView Panel',
            onPressed: () => controller.toggleChartMode(),
          )),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.loadAllData(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Get.snackbar('Add Trading', 'Create new trading strategy');
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, thickness: 1.0, color: Color(0xFF2A2E39)),
        ),
      ),
      body: Obx(() {
        final selected = controller.selectedTrading.value;
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TradingView Chart Section
                  SizedBox(
                    height: 450,
                    child: TradingViewChart(
                      symbol: controller.selectedSymbol.value,
                      interval: controller.selectedInterval.value,
                      klines: controller.klines.toList(),
                      indicators: controller.indicators,
                      signals: controller.strategySignals.map((s) => {
                        'price': s.price,
                        'signal': s.signal,
                        'timestamp': s.timestamp,
                      }).toList(),
                      theme: 'dark',
                      datafeedUrl: controller.datafeedUrl,
                      useTradingViewWidget: controller.useTradingViewWidget.value,
                      onSymbolChanged: (newSymbol) => controller.changeSymbol(newSymbol),
                      onLoadMoreKlines: (oldestTime) => controller.loadMoreKlines(oldestTime),
                    ),
                  ),
                  const Divider(color: Color(0xFF2A2E39), height: 1),

                  // Filter & Search Section
                  _buildSearchFilterSection(context),

                  const Divider(color: Color(0xFF2A2E39), height: 1),

                  // Tradings Table / List Section
                  _buildTradingsTable(context),
                ],
              ),
            ),

            // Trading Details Bottom Sheet / Drawer Overlay
            if (selected != null)
              _buildTradingDrawerOverlay(context, selected),
          ],
        );
      }),
    );
  }

  Widget _buildIntervalChips(BuildContext context) {
    final intervals = [
      {'label': '1m', 'value': '1m'},
      {'label': '15m', 'value': '15m'},
      {'label': '4h', 'value': '4h'},
      {'label': '1d', 'value': '1d'},
    ];
    return Row(
      children: intervals.map((item) {
        final label = item['label']!;
        final value = item['value']!;
        final isSelected = KlinesApi.normalizeInterval(controller.selectedInterval.value) == value;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: InkWell(
            onTap: () => controller.changeInterval(value),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2962FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildSearchFilterSection(BuildContext context) {
    return Container(
      color: const Color(0xFF1E222D),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search trading...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                filled: true,
                fillColor: const Color(0xFF131722),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => controller.searchQuery.value = val,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF131722),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: controller.statusFilter.value.isEmpty ? 'All' : controller.statusFilter.value,
              dropdownColor: const Color(0xFF1E222D),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              underline: const SizedBox(),
              items: ['All', 'complete', 'pending', 'canceled'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.capitalizeFirst ?? status),
                );
              }).toList(),
              onChanged: (val) {
                controller.statusFilter.value = (val == 'All') ? '' : (val ?? '');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingsTable(BuildContext context) {
    if (controller.isLoadingTradings.value) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    if (controller.tradingsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No tradings data found',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return TvTableTheme.buildStickyTable(
      firstColumn: const DataColumn(label: Text('SYMBOL', style: TvTableTheme.headerTextStyle)),
      remainingColumns: const [
        DataColumn(label: Text('TYPE', style: TvTableTheme.headerTextStyle)),
        DataColumn(label: Text('SIDE', style: TvTableTheme.headerTextStyle)),
        DataColumn(label: Text('PRICE', style: TvTableTheme.headerTextStyle)),
        DataColumn(label: Text('QUANTITY', style: TvTableTheme.headerTextStyle)),
        DataColumn(label: Text('STATUS', style: TvTableTheme.headerTextStyle)),
        DataColumn(label: Text('ACTION', style: TvTableTheme.headerTextStyle)),
      ],
      itemCount: controller.tradingsList.length,
      onSelectRow: (index) => controller.selectTrading(controller.tradingsList[index]),
      firstCellBuilder: (index) {
        final item = controller.tradingsList[index];
        return DataCell(Text(item['symbol'].toString(), style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontWeight: FontWeight.w600, fontSize: 12.5, letterSpacing: 0.3)));
      },
      remainingCellsBuilder: (index) {
        final item = controller.tradingsList[index];
        final isBuy = item['side'] == 'BUY';
        return [
          DataCell(Text(item['type'].toString(), style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12))),
          DataCell(
            Text(
              item['side'].toString(),
              style: TextStyle(
                color: isBuy ? TvTableTheme.tvGreen : TvTableTheme.tvRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          DataCell(Text('\$${item['price']}', style: TvTableTheme.numberTextStyle)),
          DataCell(Text('${item['quantity']}', style: TvTableTheme.numberTextStyle)),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: item['status'] == 'complete'
                    ? TvTableTheme.tvGreen.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['status'].toString(),
                style: TextStyle(
                  color: item['status'] == 'complete' ? TvTableTheme.tvGreen : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          DataCell(
            IconButton(
              icon: const Icon(Icons.info_outline, color: TvTableTheme.tvBlue, size: 18),
              onPressed: () => controller.selectTrading(item),
            ),
          ),
        ];
      },
    );
  }

  Widget _buildTradingDrawerOverlay(BuildContext context, Map<String, dynamic> item) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: 320,
      child: Material(
        elevation: 8,
        color: const Color(0xFF1E222D),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF131722),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trading Details (${item['id']})',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => controller.closeTradingDrawer(),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2A2E39), height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildDetailRow('ID', item['id'].toString()),
                    _buildDetailRow('Symbol', item['symbol'].toString()),
                    _buildDetailRow('Type', item['type'].toString()),
                    _buildDetailRow('Side', item['side'].toString()),
                    _buildDetailRow('Price', '\$${item['price']}'),
                    _buildDetailRow('Quantity', item['quantity'].toString()),
                    _buildDetailRow('Status', item['status'].toString()),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TvTableTheme.tvBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        controller.closeTradingDrawer();
                        Get.toNamed(
                          AppRoutes.binanceSpotPositionsCalc,
                          arguments: {
                            'symbol': item['symbol'].toString(),
                            'entryPrice': double.tryParse(item['price'].toString()) ?? 0.0,
                          },
                        );
                      },
                      icon: const Icon(Icons.exposure_rounded, size: 18),
                      label: const Text('带入 Positions Calc'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TvTableTheme.tvCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        controller.closeTradingDrawer();
                        Get.toNamed(
                          AppRoutes.binanceSpotGamblingCalc,
                          arguments: {
                            'symbol': item['symbol'].toString(),
                            'entryPrice': double.tryParse(item['price'].toString()) ?? 0.0,
                          },
                        );
                      },
                      icon: const Icon(Icons.calculate_rounded, size: 18),
                      label: const Text('带入 Gambling Calc'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
