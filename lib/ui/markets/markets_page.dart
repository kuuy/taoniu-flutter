import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
import '../components/mini_sparkline.dart';
import 'markets_controller.dart';

class MarketsPage extends GetView<MarketsController> {
  const MarketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(
        title: 'Markets & Tickers',
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: TvTableTheme.tvTextPrimary, size: 20),
            onPressed: () {
              Get.snackbar(
                '排序',
                '行情列表已按 24h 涨跌幅排序',
                snackPosition: SnackPosition.TOP,
                backgroundColor: TvTableTheme.tvHeaderBg,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Filter Section
          _buildSearchAndFilterHeader(),

          // 2. Category Filter Chips
          _buildCategoryChips(),

          const Divider(height: 1, color: TvTableTheme.tvBorderColor),

          // 3. Ticker List
          Expanded(
            child: Obx(() {
              final list = controller.filteredTickers;
              if (list.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, color: TvTableTheme.tvTextSecondary, size: 48),
                      SizedBox(height: 12),
                      Text('未找到匹配的币种', style: TextStyle(color: TvTableTheme.tvTextSecondary)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: list.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: TvTableTheme.tvBorderColor),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _buildTickerTile(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      color: TvTableTheme.tvHeaderBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: '搜索标的 / 币种 (BTC, ETH, SOL...)',
          hintStyle: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: TvTableTheme.tvTextSecondary, size: 18),
          filled: true,
          fillColor: TvTableTheme.tvCanvasBg,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: TvTableTheme.tvBorderColor),
          ),
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
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      color: TvTableTheme.tvHeaderBg,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = controller.categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat;
            return ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : TvTableTheme.tvTextSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: TvTableTheme.tvBlue,
              backgroundColor: TvTableTheme.tvCanvasBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? TvTableTheme.tvBlue : TvTableTheme.tvBorderColor),
              ),
              onSelected: (selected) {
                if (selected) controller.selectedCategory.value = cat;
              },
            );
          });
        },
      ),
    );
  }

  Widget _buildTickerTile(MarketTicker item) {
    final isPositive = item.change24h >= 0;
    final pnlColor = isPositive ? TvTableTheme.tvGreen : TvTableTheme.tvRed;
    final sign = isPositive ? '+' : '';

    // Mock trend line generator for sparkline
    final List<double> sparkData = isPositive
        ? [item.price * 0.96, item.price * 0.97, item.price * 0.965, item.price * 0.99, item.price]
        : [item.price * 1.04, item.price * 1.03, item.price * 1.035, item.price * 1.01, item.price];

    return InkWell(
      onTap: () => controller.openTradingChart(item),
      splashColor: TvTableTheme.tvBlue.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: TvTableTheme.tvCanvasBg,
        child: Row(
          children: [
            // Favorite Toggle Icon
            Obx(
              () => IconButton(
                constraints: const BoxConstraints(maxWidth: 32),
                padding: EdgeInsets.zero,
                icon: Icon(
                  item.isFavorite.value ? Icons.star : Icons.star_border,
                  color: item.isFavorite.value ? Colors.amber : TvTableTheme.tvTextSecondary,
                  size: 20,
                ),
                onPressed: () => controller.toggleFavorite(item),
              ),
            ),
            const SizedBox(width: 8),

            // Base Asset / Quote Asset
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.baseAsset,
                        style: const TextStyle(
                          color: TvTableTheme.tvTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' / ${item.quoteAsset}',
                        style: const TextStyle(
                          color: TvTableTheme.tvTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '24h Vol ${item.volume24h}',
                    style: TextStyle(
                      color: TvTableTheme.tvTextSecondary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Sparkline Graph
            Expanded(
              flex: 2,
              child: Center(
                child: MiniSparkline(
                  data: sparkData,
                  color: pnlColor,
                  width: 55,
                  height: 24,
                ),
              ),
            ),

            // Price & 24h PnL Badge
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${item.price < 1 ? item.price.toStringAsFixed(4) : item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: TvTableTheme.tvTextPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: pnlColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: pnlColor.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: Text(
                      '$sign${item.change24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: pnlColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
