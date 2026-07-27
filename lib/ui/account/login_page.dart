import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Header Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TvTableTheme.tvBlue.withValues(alpha: 0.15),
                    border: Border.all(color: TvTableTheme.tvBlue.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    size: 40,
                    color: TvTableTheme.tvBlue,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Taoniu Quant',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TvTableTheme.tvTextPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '币安现货高频量化交易系统',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TvTableTheme.tvTextSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input Field
                TextField(
                  controller: controller.emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: TvTableTheme.tvHeaderBg,
                    hintText: '电子邮箱 / Email',
                    hintStyle: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: TvTableTheme.tvBlue),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined, color: TvTableTheme.tvTextSecondary, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input Field
                TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: TvTableTheme.tvHeaderBg,
                    hintText: '密码 / Password',
                    hintStyle: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: TvTableTheme.tvBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: TvTableTheme.tvBlue),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline, color: TvTableTheme.tvTextSecondary, size: 20),
                  ),
                ),
                const SizedBox(height: 32),

                // Login Submit Button
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TvTableTheme.tvBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '立即安全登录',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
