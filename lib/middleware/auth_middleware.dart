import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';

/// GetX Middleware to intercept protected routes when user is unauthenticated.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Safely check if access token is stored
    if (!Get.isRegistered<SharedPreferences>()) {
      return null;
    }
    final prefs = Get.find<SharedPreferences>();
    final accessToken = prefs.getString('ACCESS_TOKEN') ?? '';

    if (accessToken.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
