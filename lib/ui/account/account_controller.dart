import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class AccountController extends GetxController {
  // User Profile
  final username = 'Taoniu Trader'.obs;
  final email = 'trader@taoniu.io'.obs;
  final uid = '88291043'.obs;
  final vipLevel = 'VIP 2'.obs;

  // Assets & PnL
  final totalAssetUsdt = 35842.50.obs;
  final todayPnlUsdt = 1240.80.obs;
  final todayPnlPercent = 3.58.obs;

  // Quant Trading Performance
  final winRate = 68.5.obs;
  final totalTrades = 1248.obs;
  final activeStrategiesCount = 6.obs;

  // Binance API Key Credentials
  final binanceApiKey = ''.obs;
  final binanceSecretKey = ''.obs;
  final isApiKeyVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('USER_EMAIL');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      email.value = savedEmail;
      username.value = savedEmail.split('@').first;
    }

    final key = prefs.getString('BINANCE_API_KEY') ?? '';
    final secret = prefs.getString('BINANCE_SECRET_KEY') ?? '';
    binanceApiKey.value = key;
    binanceSecretKey.value = secret;
  }

  Future<void> saveApiKey(String apiKey, String secretKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('BINANCE_API_KEY', apiKey);
    await prefs.setString('BINANCE_SECRET_KEY', secretKey);
    binanceApiKey.value = apiKey;
    binanceSecretKey.value = secretKey;

    Get.back();
    Get.snackbar(
      '密钥设置',
      '币安 API Key 已成功保存',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E222D),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: Color(0xFF089981)),
    );
  }

  void toggleApiKeyVisibility() {
    isApiKeyVisible.value = !isApiKeyVisible.value;
  }

  String get maskedApiKey {
    if (binanceApiKey.value.isEmpty) return '未绑定 API Key';
    if (binanceApiKey.value.length <= 8) return '********';
    return '${binanceApiKey.value.substring(0, 4)}...${binanceApiKey.value.substring(binanceApiKey.value.length - 4)}';
  }

  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1E222D),
        title: const Text('退出登录', style: TextStyle(color: Colors.white)),
        content: const Text('确定要退出当前账号吗？退出后需要重新登录认证。', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF23645)),
            onPressed: () => Get.back(result: true),
            child: const Text('确认退出', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ACCESS_TOKEN');
      await prefs.remove('REFRESH_TOKEN');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
