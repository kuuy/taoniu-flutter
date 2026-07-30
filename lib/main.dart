import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/token_refresh_service.dart';
import 'ui/components/tables/tradingview_table_theme.dart';
import 'ui/components/app_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize and register global SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  // Start background auto-refresh timer for JWT tokens
  TokenRefreshService().startAutoRefresh(interval: const Duration(minutes: 15));

  runApp(const TaoniuApp());
}

class TaoniuApp extends StatelessWidget {
  const TaoniuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Taoniu Quant',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: TvTableTheme.tvCanvasBg,
        cardColor: TvTableTheme.tvHeaderBg,
        colorScheme: const ColorScheme.dark(
          primary: TvTableTheme.tvBlue,
          surface: TvTableTheme.tvHeaderBg,
          onSurface: TvTableTheme.tvTextPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: TvTableTheme.tvHeaderBg,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: TvTableTheme.tvHeaderBg,
          selectedItemColor: TvTableTheme.tvBlue,
          unselectedItemColor: TvTableTheme.tvTextSecondary,
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      builder: (context, child) {
        return child!;
      },
    );
  }
}
