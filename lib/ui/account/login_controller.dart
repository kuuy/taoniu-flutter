import 'dart:convert';
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
      Get.snackbar('Error', 'Please enter email and password', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _jwtApi.signIn(email: email, password: password);
      
      // Decrypt the JWE response
      final decryptedString = await JweUtil.decrypt(response.data.toString());
      final jsonData = jsonDecode(decryptedString);

      // Extract tokens from data
      final data = jsonData['data'];
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ACCESS_TOKEN', accessToken);
      if (refreshToken != null) {
        await prefs.setString('REFRESH_TOKEN', refreshToken);
      }

      Get.snackbar('Success', 'Logged in successfully', snackPosition: SnackPosition.BOTTOM);
      Get.offAllNamed(AppRoutes.mainTab);
    } catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
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
