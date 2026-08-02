import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taoniu/ui/account/account_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccountController Logic Unit Tests', () {
    late AccountController controller;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      controller = Get.put(AccountController());
    });

    test('initial values for profile and metrics', () {
      expect(controller.username.value, isNotEmpty);
      expect(controller.vipLevel.value, equals('VIP 2'));
      expect(controller.totalAssetUsdt.value, greaterThan(0));
    });

    test('maskedApiKey formats API key correctly', () {
      controller.binanceApiKey.value = '';
      expect(controller.maskedApiKey, equals('未绑定 API Key'));

      controller.binanceApiKey.value = '1234';
      expect(controller.maskedApiKey, equals('********'));

      controller.binanceApiKey.value = 'AKIAIOSFODNN7EXAMPLE';
      expect(controller.maskedApiKey, equals('AKIA...MPLE'));
    });

    test('toggleApiKeyVisibility flips boolean flag', () {
      expect(controller.isApiKeyVisible.value, isFalse);
      controller.toggleApiKeyVisibility();
      expect(controller.isApiKeyVisible.value, isTrue);
    });
  });
}
