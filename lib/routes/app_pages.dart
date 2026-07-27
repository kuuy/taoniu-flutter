import 'package:get/get.dart';
import 'app_routes.dart';
import '../ui/splash/splash_page.dart';
import '../ui/splash/splash_controller.dart';
import '../ui/account/login_page.dart';
import '../ui/account/login_controller.dart';
import '../ui/main_tab/main_tab_page.dart';
import '../ui/main_tab/main_tab_controller.dart';
import '../ui/home/home_controller.dart';
import '../ui/markets/markets_controller.dart';
import '../ui/plans/plans_controller.dart';
import '../ui/account/account_controller.dart';

import '../ui/cryptos/binance/spot/analysis/tradings/scalping/scalping_page.dart';
import '../ui/cryptos/binance/spot/analysis/tradings/scalping/scalping_binding.dart';
import '../ui/cryptos/binance/spot/indicators/indicators_page.dart';
import '../ui/cryptos/binance/spot/indicators/indicators_binding.dart';
import '../ui/cryptos/binance/spot/indicators/ranking/ranking_page.dart';
import '../ui/cryptos/binance/spot/indicators/ranking/ranking_binding.dart';
import '../ui/cryptos/binance/spot/orders/orders_page.dart';
import '../ui/cryptos/binance/spot/orders/orders_binding.dart';
import '../ui/cryptos/binance/spot/plans/plans_page.dart';
import '../ui/cryptos/binance/spot/plans/plans_binding.dart';
import '../ui/cryptos/binance/spot/positions/positions_page.dart';
import '../ui/cryptos/binance/spot/positions/positions_binding.dart';
import '../ui/cryptos/binance/spot/scalping/scalping_page.dart';
import '../ui/cryptos/binance/spot/scalping/scalping_binding.dart';
import '../ui/cryptos/binance/spot/strategies/strategies_page.dart';
import '../ui/cryptos/binance/spot/strategies/strategies_binding.dart';
import '../ui/cryptos/binance/spot/tickers/ranking/ranking_page.dart';
import '../ui/cryptos/binance/spot/tickers/ranking/ranking_binding.dart';
import '../ui/cryptos/binance/spot/tickers/realtime/realtime_tickers_page.dart';
import '../ui/cryptos/binance/spot/tickers/realtime/realtime_tickers_binding.dart';
import '../ui/cryptos/binance/spot/tradings/tradings_page.dart';
import '../ui/cryptos/binance/spot/tradings/tradings_binding.dart';
import '../ui/cryptos/binance/spot/tradings/scalping/scalping_page.dart';
import '../ui/cryptos/binance/spot/tradings/scalping/scalping_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.mainTab,
      page: () => const MainTabPage(),
      binding: BindingsBuilder(() {
        Get.put(MainTabController());
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => MarketsController());
        Get.lazyPut(() => PlansController());
        Get.lazyPut(() => AccountController());
      }),
    ),
    GetPage(
      name: AppRoutes.binanceSpotAnalysisTradingsScalping,
      page: () => const AnalysisTradingsScalpingPage(),
      binding: AnalysisTradingsScalpingBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotIndicators,
      page: () => const IndicatorsPage(),
      binding: IndicatorsBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotIndicatorsRanking,
      page: () => const IndicatorsRankingPage(),
      binding: IndicatorsRankingBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotOrders,
      page: () => const OrdersPage(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotPlans,
      page: () => const PlansPage(),
      binding: PlansBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotPositions,
      page: () => const PositionsPage(),
      binding: PositionsBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotScalping,
      page: () => const ScalpingPage(),
      binding: ScalpingBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotStrategies,
      page: () => const StrategiesPage(),
      binding: StrategiesBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotTickersRanking,
      page: () => const TickersRankingPage(),
      binding: TickersRankingBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotTickersRealtime,
      page: () => const RealtimeTickersPage(),
      binding: RealtimeTickersBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotTradings,
      page: () => const TradingsPage(),
      binding: TradingsBinding(),
    ),
    GetPage(
      name: AppRoutes.binanceSpotTradingsScalping,
      page: () => const TradingsScalpingPage(),
      binding: TradingsScalpingBinding(),
    ),
  ];
}
