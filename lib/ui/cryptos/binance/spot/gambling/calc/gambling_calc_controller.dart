import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/gambling_api.dart';
import 'package:taoniu/models/binance/spot/gambling_calc.dart';

class GamblingCalcController extends GetxController {
  final symbolController = TextEditingController(text: 'BTCUSDT');
  final entryPriceController = TextEditingController();
  final entryQuantityController = TextEditingController();

  final selectedSide = 1.obs; // 1: BUY / LONG, 2: SELL / SHORT
  final isLoading = false.obs;
  final result = Rxn<GamblingCalcResult>();

  @override
  void onInit() {
    super.onInit();
    calculate();
  }

  @override
  void onClose() {
    symbolController.dispose();
    entryPriceController.dispose();
    entryQuantityController.dispose();
    super.onClose();
  }

  void calculate() async {
    final symbol = symbolController.text.trim().toUpperCase();
    if (symbol.isEmpty) {
      Get.snackbar('输入错误', '请输入交易对名称 (Symbol)');
      return;
    }

    final entryPrice = double.tryParse(entryPriceController.text.trim());
    final entryQuantity = double.tryParse(entryQuantityController.text.trim());

    try {
      isLoading(true);
      final response = await GamblingApi.calc(
        symbol: symbol,
        side: selectedSide.value,
        entryPrice: entryPrice,
        entryQuantity: entryQuantity,
      );

      if (response.isSuccess && response.data != null) {
        result.value = response.data;
      } else {
        result.value = null;
      }
    } catch (e) {
      Get.snackbar('计算失败', e.toString());
      result.value = null;
    } finally {
      isLoading(false);
    }
  }
}
