import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(
        title: 'Taoniu Quant Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: TvTableTheme.tvTextPrimary, size: 22),
            onPressed: () {
              Get.snackbar(
                '系统通知',
                '暂无最新系统告警消息',
                snackPosition: SnackPosition.TOP,
                backgroundColor: TvTableTheme.tvHeaderBg,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dashboard Overview Banner
            _buildDashboardBanner(),
            const SizedBox(height: 20),

            // 2. Section Title: Modules Grid
            const Text(
              'Binance Spot 功能大厅',
              style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 3. Grid of Quant Modules
            _buildModulesGrid(),
            const SizedBox(height: 20),

            // 4. Live Strategy Signals Activity Feed
            _buildSignalsActivityCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBanner() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E222D), Color(0xFF181C27)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TvTableTheme.tvBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: Colors.amber, size: 20),
                  SizedBox(width: 6),
                  Text(
                    '币安现货高频量化中枢',
                    style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TvTableTheme.tvGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: TvTableTheme.tvGreen),
                    SizedBox(width: 4),
                    Text(
                      '实盘运行中',
                      style: TextStyle(color: TvTableTheme.tvGreen, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderMetric('核心交易标的', 'BTC / ETH / SOL'),
              _buildHeaderMetric('默认策略', 'Scalping & Grid'),
              _buildHeaderMetric('通信状态', 'JWE Encrypted'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildModulesGrid() {
    final modules = [
      {
        'title': 'Spot Tradings',
        'subtitle': 'TradingView 交互 K线与指标',
        'icon': Icons.candlestick_chart,
        'color': TvTableTheme.tvBlue,
        'route': AppRoutes.binanceSpotTradings,
      },
      {
        'title': 'Tradings Scalping',
        'subtitle': '剥头皮高频策略执行',
        'icon': Icons.trending_up,
        'color': TvTableTheme.tvGreen,
        'route': AppRoutes.binanceSpotTradingsScalping,
      },
      {
        'title': 'Scalping Analysis',
        'subtitle': '高频剥头皮收益与胜率统计',
        'icon': Icons.analytics,
        'color': Colors.amber,
        'route': AppRoutes.binanceSpotAnalysisTradingsScalping,
      },
      {
        'title': 'Strategies',
        'subtitle': '策略信号分布与绩效',
        'icon': Icons.alt_route,
        'color': Colors.purpleAccent,
        'route': AppRoutes.binanceSpotStrategies,
      },
      {
        'title': 'Indicators Ranking',
        'subtitle': '技术指标量化排行榜',
        'icon': Icons.bar_chart,
        'color': Colors.tealAccent,
        'route': AppRoutes.binanceSpotIndicatorsRanking,
      },
      {
        'title': 'Tickers Ranking',
        'subtitle': '全网币种异动与排行榜',
        'icon': Icons.show_chart,
        'color': Colors.orangeAccent,
        'route': AppRoutes.binanceSpotTickersRanking,
      },
      {
        'title': 'Realtime Tickers',
        'subtitle': 'WebSocket 实时行情推送与信号',
        'icon': Icons.online_prediction,
        'color': Colors.lightGreenAccent,
        'route': AppRoutes.binanceSpotTickersRealtime,
      },
      {
        'title': 'Positions',
        'subtitle': '持仓明细与仓位风险监控',
        'icon': Icons.account_balance_wallet,
        'color': Colors.indigoAccent,
        'route': AppRoutes.binanceSpotPositions,
      },
      {
        'title': 'Orders',
        'subtitle': '活动挂单与历史成交明细',
        'icon': Icons.list_alt,
        'color': Colors.cyanAccent,
        'route': AppRoutes.binanceSpotOrders,
      },
      {
        'title': 'Plans',
        'subtitle': '自动化交易/建仓计划',
        'icon': Icons.next_plan,
        'color': Colors.deepOrangeAccent,
        'route': AppRoutes.binanceSpotPlans,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final item = modules[index];
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;
        final route = item['route'] as String;

        return Card(
          color: TvTableTheme.tvHeaderBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: TvTableTheme.tvBorderColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Get.toNamed(route),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: TvTableTheme.tvTextSecondary, size: 12),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          color: TvTableTheme.tvTextPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['subtitle'] as String,
                        style: const TextStyle(
                          color: TvTableTheme.tvTextSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignalsActivityCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TvTableTheme.tvBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.sensors, color: TvTableTheme.tvGreen, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '实时策略信号流',
                    style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                'Live',
                style: TextStyle(color: TvTableTheme.tvGreen, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSignalItem('BUY', 'BTCUSDT', '\$64,250.80', '1分钟前', TvTableTheme.tvGreen),
          const Divider(height: 16, color: TvTableTheme.tvBorderColor),
          _buildSignalItem('SELL', 'ETHUSDT', '\$3,485.00', '5分钟前', TvTableTheme.tvRed),
          const Divider(height: 16, color: TvTableTheme.tvBorderColor),
          _buildSignalItem('BUY', 'SOLUSDT', '\$144.90', '12分钟前', TvTableTheme.tvGreen),
        ],
      ),
    );
  }

  Widget _buildSignalItem(String type, String symbol, String price, String time, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                type,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(symbol, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            Text(price, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            Text(time, style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
