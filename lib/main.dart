import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/token_refresh_service.dart';
import 'ui/components/app_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Start background auto-refresh timer for JWT tokens
  TokenRefreshService().startAutoRefresh(interval: const Duration(minutes: 15));

  runApp(const TaoniuApp());
}

class TaoniuApp extends StatelessWidget {
  const TaoniuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Taoniu',
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      builder: (context, child) {
        return child!;
      },
    );
  }
}
