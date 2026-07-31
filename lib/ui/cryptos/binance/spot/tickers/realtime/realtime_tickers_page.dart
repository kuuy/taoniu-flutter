import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taoniu/models/cryptos/binance/spot/spot_ticker.dart';
import 'package:taoniu/routes/app_routes.dart';
import 'package:taoniu/services/binance_spot_ws_service.dart';
import 'package:taoniu/ui/components/tables/tradingview_table_theme.dart';
import 'realtime_tickers_controller.dart';

class RealtimeTickersPage extends GetView<RealtimeTickersController> {
  const RealtimeTickersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(
        titleWidget: Row(
          children: [
            const Text(
              'Binance Spot 实时行情',
              style: TextStyle(
                color: TvTableTheme.tvTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => _buildWsStatusBadge(controller.wsStatus.value)),
          ],
        ),
        title: 'Binance Spot 实时行情',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: TvTableTheme.tvTextPrimary, size: 20),
            tooltip: '添加订阅标的',
            onPressed: () => _showAddSymbolDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: TvTableTheme.tvTextPrimary, size: 20),
            tooltip: '重新连接 WebSocket',
            onPressed: () => controller.reconnect(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOverviewHeader(),
          _buildSearchBar(),
          _buildSortOptionsBar(),
          const Divider(height: 1, color: TvTableTheme.tvBorderColor),

          // Main Tickers List
          Expanded(
            child: Obx(() {
              if (controller.isLoadingRanking.value && controller.activeSymbols.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(TvTableTheme.tvGreen),
                  ),
                );
              }

              final list = controller.filteredTickers;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, color: TvTableTheme.tvTextSecondary.withValues(alpha: 0.4), size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        '暂无匹配标的行情',
                        style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '请通过搜索框过滤或添加订阅热门交易对',
                        style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _showAddSymbolDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('添加标的'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TvTableTheme.tvBlue,
                          side: const BorderSide(color: TvTableTheme.tvBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: TvTableTheme.tvBorderColor,
                ),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return RealtimeTickerRowWidget(
                    key: ValueKey(item.symbol),
                    item: item,
                    index: index,
                    onTap: () => _showTickerActionSheet(context, item),
                    onDismissed: () => controller.removeSymbol(item.symbol),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewHeader() {
    return Obx(() {
      final total = controller.activeSymbols.length;
      final gainers = controller.gainersCount;
      final losers = controller.losersCount;
      final totalRatio = (gainers + losers) > 0 ? (gainers / (gainers + losers)) : 0.5;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: TvTableTheme.tvHeaderBg,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart_rounded, color: TvTableTheme.tvCyan, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '订阅标的: $total 个',
                      style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '上涨 $gainers',
                      style: const TextStyle(color: TvTableTheme.tvGreen, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    const Text(' / ', style: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 11.5)),
                    Text(
                      '下跌 $losers',
                      style: const TextStyle(color: TvTableTheme.tvRed, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: totalRatio,
                  backgroundColor: TvTableTheme.tvRed.withValues(alpha: 0.8),
                  valueColor: const AlwaysStoppedAnimation<Color>(TvTableTheme.tvGreen),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSortOptionsBar() {
    return Container(
      color: TvTableTheme.tvHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          const Text('排序:', style: TextStyle(color: TvTableTheme.tvTextHeader, fontSize: 11)),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() {
                final currentField = controller.sortField.value;
                final isAsc = controller.sortAscending.value;

                return Row(
                  children: [
                    _buildSortBtn(TickerSortField.change24h, '24h涨跌', currentField, isAsc),
                    _buildSortBtn(TickerSortField.price, '最新价', currentField, isAsc),
                    _buildSortBtn(TickerSortField.volume, '24h成交量', currentField, isAsc),
                    _buildSortBtn(TickerSortField.symbol, '名称', currentField, isAsc),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBtn(TickerSortField field, String label, TickerSortField currentField, bool isAsc) {
    final isSelected = currentField == field;
    final arrow = isAsc ? ' ⬆' : ' ⬇';

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => controller.toggleSort(field),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? TvTableTheme.tvBlue.withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? TvTableTheme.tvBlue : TvTableTheme.tvBorderColor,
              width: 0.8,
            ),
          ),
          child: Text(
            '$label${isSelected ? arrow : ''}',
            style: TextStyle(
              color: isSelected ? TvTableTheme.tvBlue : TvTableTheme.tvTextSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWsStatusBadge(WsConnectionStatus status) {
    Color bg;
    String label;
    IconData icon;

    switch (status) {
      case WsConnectionStatus.connected:
        bg = TvTableTheme.tvGreen;
        label = '已连接';
        icon = Icons.check_circle;
        break;
      case WsConnectionStatus.connecting:
        bg = Colors.amber;
        label = '连接中...';
        icon = Icons.sync;
        break;
      case WsConnectionStatus.error:
        bg = TvTableTheme.tvRed;
        label = '连接异常';
        icon = Icons.error;
        break;
      case WsConnectionStatus.disconnected:
        bg = TvTableTheme.tvTextSecondary;
        label = '已断开';
        icon = Icons.offline_bolt;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bg.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: bg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: bg, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: TvTableTheme.tvHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        children: [
          SizedBox(
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
                hintText: '搜索标的 (如 BTC, SOL, DOGE...)',
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
          const SizedBox(height: 6),
          _buildPresetChips(),
        ],
      ),
    );
  }

  Widget _buildPresetChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.presetSymbols.map((sym) {
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Obx(() {
              final isSubscribed = controller.activeSymbols.contains(sym);
              return ActionChip(
                label: Text(
                  sym,
                  style: TextStyle(
                    color: isSubscribed ? TvTableTheme.tvCyan : TvTableTheme.tvTextSecondary,
                    fontSize: 10.5,
                    fontWeight: isSubscribed ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                backgroundColor: TvTableTheme.tvCanvasBg,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSubscribed ? TvTableTheme.tvCyan : TvTableTheme.tvBorderColor,
                  ),
                ),
                onPressed: () {
                  if (!isSubscribed) {
                    controller.addSymbol(sym);
                  } else {
                    controller.searchQuery.value = sym;
                  }
                },
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  void _showAddSymbolDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TvTableTheme.tvHeaderBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: TvTableTheme.tvBorderColor),
          ),
          title: const Text(
            '添加订阅标的',
            style: TextStyle(color: TvTableTheme.tvTextPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14),
            textCapitalization: TextCapitalization.characters,
            strutStyle: const StrutStyle(
              fontSize: 14,
              height: 1.0,
              leading: 0,
              forceStrutHeight: true,
            ),
            decoration: InputDecoration(
              hintText: '请输入交易对 (如 DOGEUSDT)',
              hintStyle: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 13),
              filled: true,
              fillColor: TvTableTheme.tvCanvasBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消', style: TextStyle(color: TvTableTheme.tvTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TvTableTheme.tvBlue,
              ),
              onPressed: () {
                final symbol = textController.text.trim();
                if (symbol.isNotEmpty) {
                  controller.addSymbol(symbol);
                }
                Navigator.of(context).pop();
              },
              child: const Text('订阅', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showTickerActionSheet(BuildContext context, SpotTicker item) {
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
                Obx(() => Text(
                      '最新价: ${item.price.value}',
                      style: const TextStyle(color: TvTableTheme.tvCyan, fontSize: 13, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.exposure_rounded, color: TvTableTheme.tvBlue),
              title: const Text('带入价格至 Positions Calc (仓位计算器)', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotPositionsCalc,
                  arguments: {
                    'symbol': item.symbol,
                    'entryPrice': item.price.value,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate_rounded, color: TvTableTheme.tvCyan),
              title: const Text('带入价格至 Gambling Calc (Gambling 计算器)', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5)),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.binanceSpotGamblingCalc,
                  arguments: {
                    'symbol': item.symbol,
                    'entryPrice': item.price.value,
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
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: TvTableTheme.tvRed),
              title: const Text('取消此标的订阅', style: TextStyle(color: TvTableTheme.tvRed, fontSize: 13.5)),
              onTap: () {
                Get.back();
                controller.removeSymbol(item.symbol);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RealtimeTickerRowWidget extends StatefulWidget {
  final SpotTicker item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const RealtimeTickerRowWidget({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  State<RealtimeTickerRowWidget> createState() => _RealtimeTickerRowWidgetState();
}

class _RealtimeTickerRowWidgetState extends State<RealtimeTickerRowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Color?> _colorAnimation;
  late double _prevPrice;
  Worker? _priceWorker;

  @override
  void initState() {
    super.initState();
    _prevPrice = widget.item.price.value;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _bindPriceWorker();
  }

  void _bindPriceWorker() {
    _priceWorker?.dispose();
    _priceWorker = ever<double>(widget.item.price, (newPrice) {
      if (!mounted) return;
      if (newPrice != _prevPrice && _prevPrice > 0) {
        final isUp = newPrice > _prevPrice;
        _prevPrice = newPrice;

        final flashColor = isUp
            ? TvTableTheme.tvGreen.withValues(alpha: 0.45)
            : TvTableTheme.tvRed.withValues(alpha: 0.45);

        setState(() {
          _colorAnimation = ColorTween(
            begin: flashColor,
            end: Colors.transparent,
          ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
        });

        _animController.forward(from: 0.0);
      } else {
        _prevPrice = newPrice;
      }
    });
  }

  @override
  void didUpdateWidget(RealtimeTickerRowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _prevPrice = widget.item.price.value;
      _bindPriceWorker();
    }
  }

  @override
  void dispose() {
    _priceWorker?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAltRow = widget.index % 2 == 1;
    final baseRowBg = isAltRow ? TvTableTheme.tvRowAltBg : TvTableTheme.tvCanvasBg;

    return Dismissible(
      key: Key(widget.item.symbol),
      direction: DismissDirection.endToStart,
      background: Container(
        color: TvTableTheme.tvRed.withValues(alpha: 0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => widget.onDismissed(),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final flashColor = _colorAnimation.value ?? Colors.transparent;
          final bg = Color.alphaBlend(flashColor, baseRowBg);

          return InkWell(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: bg,
            child: Row(
              children: [
                // Left Column: Symbol Name & Signal Badges
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        widget.item.symbol,
                        style: const TextStyle(
                          color: TvTableTheme.tvTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Signal Badges (SELL, BUY)
                      Obx(() {
                        if (widget.item.signals.isEmpty) return const SizedBox.shrink();
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.item.signals.map((sig) => _buildSignalBadge(sig)).toList(),
                        );
                      }),
                    ],
                  ),
                ),

                // Middle Column: Realtime Price
                Obx(() {
                  final priceVal = widget.item.price.value;
                  final dir = widget.item.priceDirection.value;
                  final formattedPrice = _formatPrice(priceVal);

                  Color priceColor = TvTableTheme.tvTextPrimary;
                  if (dir == 1) {
                    priceColor = TvTableTheme.tvGreen; // Green up
                  } else if (dir == -1) {
                    priceColor = TvTableTheme.tvRed; // Red down
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      formattedPrice,
                      style: TextStyle(
                        color: priceColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  );
                }),

                // Right Column: 24h Change Percentage Pill Badge
                Obx(() {
                  final change = widget.item.change24h.value;
                  final isPositive = change > 0;
                  final isZero = change.abs() < 0.0001;

                  Color badgeColor;
                  String sign;

                  if (isZero) {
                    badgeColor = TvTableTheme.tvTextSecondary;
                    sign = '';
                  } else if (isPositive) {
                    badgeColor = TvTableTheme.tvGreen;
                    sign = '+';
                  } else {
                    badgeColor = TvTableTheme.tvRed;
                    sign = '';
                  }

                  final displayStr = '$sign${change.toStringAsFixed(2)}%';

                  return Container(
                    width: 78,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: Text(
                      displayStr,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildSignalBadge(String signal) {
    final isSell = signal.toUpperCase() == 'SELL';
    final color = isSell ? TvTableTheme.tvGreen : TvTableTheme.tvRed;

    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Text(
        signal.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == 0) return '0.00';
    if (price >= 100) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    if (price < 0.001) {
      return price.toStringAsExponential(2).toUpperCase();
    }
    return price.toStringAsFixed(4);
  }
}
