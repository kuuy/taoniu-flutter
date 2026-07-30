import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
import '../components/pulsing_badge.dart';
import '../components/animated_module_card.dart';
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
            icon: const Icon(Icons.notifications_none_rounded, color: TvTableTheme.tvTextPrimary, size: 22),
            onPressed: () {
              Get.snackbar(
                '系统通知',
                '暂无最新系统告警消息',
                snackPosition: SnackPosition.TOP,
                backgroundColor: TvTableTheme.tvHeaderBg,
                colorText: Colors.white,
                margin: const EdgeInsets.all(12),
                borderRadius: 10,
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
            const SizedBox(height: 22),

            // 2. Section Title: Modules Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.widgets_outlined, color: TvTableTheme.tvBlue, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Binance Spot 功能大厅',
                      style: TextStyle(
                        color: TvTableTheme.tvTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Text(
                  '12 Modules',
                  style: TextStyle(
                    color: TvTableTheme.tvTextSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Grid of Quant Modules with Micro-Animations
            _buildModulesGrid(),
            const SizedBox(height: 22),

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
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: TvTableTheme.tvBannerGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TvTableTheme.tvBorderColor, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.amber, size: 22),
                  SizedBox(width: 6),
                  Text(
                    '币安现货高频量化中枢',
                    style: TextStyle(
                      color: TvTableTheme.tvTextPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const PulsingBadge(
                label: '实盘运行中',
                color: TvTableTheme.tvGreen,
                isLive: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
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
        Text(
          label,
          style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: TvTableTheme.tvTextPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildModulesGrid() {
    final modules = [
      {
        'title': 'Spot Tradings',
        'subtitle': 'TradingView 交互 K线与指标',
        'icon': Icons.candlestick_chart_rounded,
        'color': TvTableTheme.tvBlue,
        'route': AppRoutes.binanceSpotTradings,
      },
      {
        'title': 'Tradings Scalping',
        'subtitle': '剥头皮高频策略执行',
        'icon': Icons.trending_up_rounded,
        'color': TvTableTheme.tvGreen,
        'route': AppRoutes.binanceSpotTradingsScalping,
      },
      {
        'title': 'Scalping Analysis',
        'subtitle': '高频剥头皮收益与胜率统计',
        'icon': Icons.analytics_rounded,
        'color': Colors.amber,
        'route': AppRoutes.binanceSpotAnalysisTradingsScalping,
      },
      {
        'title': 'Strategies',
        'subtitle': '策略信号分布与绩效',
        'icon': Icons.alt_route_rounded,
        'color': TvTableTheme.tvPurple,
        'route': AppRoutes.binanceSpotStrategies,
      },
      {
        'title': 'Indicators Ranking',
        'subtitle': '技术指标量化排行榜',
        'icon': Icons.bar_chart_rounded,
        'color': TvTableTheme.tvCyan,
        'route': AppRoutes.binanceSpotIndicatorsRanking,
      },
      {
        'title': 'Tickers Ranking',
        'subtitle': '全网币种异动与排行榜',
        'icon': Icons.show_chart_rounded,
        'color': Colors.orangeAccent,
        'route': AppRoutes.binanceSpotTickersRanking,
      },
      {
        'title': 'Realtime Tickers',
        'subtitle': 'WebSocket 实时行情推送与信号',
        'icon': Icons.online_prediction_rounded,
        'color': Colors.lightGreenAccent,
        'route': AppRoutes.binanceSpotTickersRealtime,
      },
      {
        'title': 'Positions',
        'subtitle': '持仓明细与仓位风险监控',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.indigoAccent,
        'route': AppRoutes.binanceSpotPositions,
      },
      {
        'title': 'Gambling Calc',
        'subtitle': '博弈止盈止损与仓位计算',
        'icon': Icons.calculate_rounded,
        'color': Colors.tealAccent,
        'route': AppRoutes.binanceSpotGamblingCalc,
      },
      {
        'title': 'Positions Calc',
        'subtitle': '补仓与分步交易价格计算',
        'icon': Icons.exposure_rounded,
        'color': Colors.lightBlueAccent,
        'route': AppRoutes.binanceSpotPositionsCalc,
      },
      {
        'title': 'Orders',
        'subtitle': '活动挂单与历史成交明细',
        'icon': Icons.list_alt_rounded,
        'color': Colors.cyanAccent,
        'route': AppRoutes.binanceSpotOrders,
      },
      {
        'title': 'Plans',
        'subtitle': '自动化交易/建仓计划',
        'icon': Icons.next_plan_rounded,
        'color': Colors.deepOrangeAccent,
        'route': AppRoutes.binanceSpotPlans,
      },
    ];


    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final item = modules[index];
        return AnimatedModuleCard(
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          icon: item['icon'] as IconData,
          accentColor: item['color'] as Color,
          onTap: () => Get.toNamed(item['route'] as String),
        );
      },
    );
  }

  Widget _buildSignalsActivityCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TvTableTheme.tvBorderColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.sensors_rounded, color: TvTableTheme.tvGreen, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '实时策略信号流',
                    style: TextStyle(
                      color: TvTableTheme.tvTextPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              PulsingBadge(
                label: 'LIVE',
                color: TvTableTheme.tvGreen,
                isLive: true,
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSignalItem('BUY', 'BTCUSDT', '\$64,250.80', '1分钟前', TvTableTheme.tvGreen),
          const Divider(height: 18, color: TvTableTheme.tvBorderColor, thickness: 0.8),
          _buildSignalItem('SELL', 'ETHUSDT', '\$3,485.00', '5分钟前', TvTableTheme.tvRed),
          const Divider(height: 18, color: TvTableTheme.tvBorderColor, thickness: 0.8),
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
            PulsingBadge(
              label: type,
              color: color,
              isLive: true,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            ),
            const SizedBox(width: 10),
            Text(
              symbol,
              style: const TextStyle(
                color: TvTableTheme.tvTextPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              price,
              style: const TextStyle(
                color: TvTableTheme.tvTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              time,
              style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
