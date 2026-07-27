import 'package:get/get.dart';
import '../../routes/app_routes.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('ACCESS_TOKEN');

    if (token != null && token.isNotEmpty) {
      Get.offNamed(AppRoutes.mainTab);
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }
}
