import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../http/jwt_api.dart';
import '../../routes/app_routes.dart';
import '../../utils/jwe.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  final JwtApi _jwtApi = JwtApi();

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('提示', '请输入电子邮箱和密码', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _jwtApi.signIn(email: email, password: password);
      
      dynamic jsonData = response.data;
      if (jsonData is String) {
        final str = jsonData.trim();
        if (JweUtil.isJweCompact(str)) {
          jsonData = jsonDecode(await JweUtil.decrypt(str));
        } else if (str.isNotEmpty) {
          jsonData = jsonDecode(str);
        }
      }

      if (jsonData is Map<String, dynamic>) {
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];
          final accessToken = data['access_token'];
          final refreshToken = data['refresh_token'];

          if (accessToken != null && accessToken.toString().isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('ACCESS_TOKEN', accessToken);
            if (refreshToken != null) {
              await prefs.setString('REFRESH_TOKEN', refreshToken);
            }

            Get.snackbar('成功', '登录成功', snackPosition: SnackPosition.BOTTOM);
            Get.offAllNamed(AppRoutes.mainTab);
            return;
          }
        }
        
        final msg = jsonData['message'] ?? jsonData['error'] ?? '登录失败，请检查账号和密码';
        Get.snackbar('登录失败', msg.toString(), snackPosition: SnackPosition.BOTTOM);
        return;
      }

      Get.snackbar('登录失败', '服务器响应格式不正确', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      String errorMsg = '登录失败，请重试';
      if (e is DioException) {
        final respData = e.response?.data;
        if (respData is Map && respData['message'] != null) {
          errorMsg = respData['message'].toString();
        } else if (respData is Map && respData['error'] != null) {
          errorMsg = respData['error'].toString();
        } else if (e.message != null && e.message!.isNotEmpty) {
          errorMsg = e.message!;
        }
      } else if (e is Exception) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }
      Get.snackbar('登录失败', errorMsg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
