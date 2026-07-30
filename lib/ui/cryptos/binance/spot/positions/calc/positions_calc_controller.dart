import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taoniu/api/cryptos/binance/spot/positions_api.dart';
import 'package:taoniu/models/binance/spot/position_calc.dart';

class PositionsCalcController extends GetxController {
  final symbolController = TextEditingController(text: 'BTCUSDT');
  final maxCapitalController = TextEditingController(text: '400000000');
  final entryPriceController = TextEditingController(text: '60000');
  final entryQuantityController = TextEditingController(text: '0.005');

  final isLoading = false.obs;
  final result = Rxn<PositionCalcResult>();

  @override
  void onInit() {
    super.onInit();
    calculate();
  }

  @override
  void onClose() {
    symbolController.dispose();
    maxCapitalController.dispose();
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

    final maxCapital = double.tryParse(maxCapitalController.text.trim());
    if (maxCapital == null || maxCapital <= 0) {
      Get.snackbar('输入错误', '请输入有效的 Max Capital');
      return;
    }

    final entryPrice = double.tryParse(entryPriceController.text.trim());
    if (entryPrice == null || entryPrice <= 0) {
      Get.snackbar('输入错误', '请输入有效的 Entry Price');
      return;
    }

    final entryQuantity = double.tryParse(entryQuantityController.text.trim());
    if (entryQuantity == null || entryQuantity <= 0) {
      Get.snackbar('输入错误', '请输入有效的 Entry Quantity');
      return;
    }

    try {
      isLoading(true);
      final response = await PositionsApi.calc(
        symbol: symbol,
        maxCapital: maxCapital,
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
