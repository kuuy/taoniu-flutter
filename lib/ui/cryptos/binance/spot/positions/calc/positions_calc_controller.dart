import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taoniu/api/cryptos/binance/spot/positions_api.dart';
import 'package:taoniu/models/cryptos/binance/spot/position_calc.dart';

class PositionsCalcController extends GetxController {
  static const String _keySymbol = 'pos_calc_symbol';
  static const String _keyMaxCapital = 'pos_calc_max_capital';
  static const String _keyEntryPrice = 'pos_calc_entry_price';
  static const String _keyEntryQuantity = 'pos_calc_entry_quantity';

  final symbolController = TextEditingController(text: 'BTCUSDT');
  final maxCapitalController = TextEditingController(text: '400000000');
  final entryPriceController = TextEditingController(text: '60000');
  final entryQuantityController = TextEditingController(text: '0.005');

  final currentSymbol = 'BTCUSDT'.obs;
  final presetSymbols = const ['BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT', 'DOGEUSDT', 'XRPUSDT'];

  final isLoading = false.obs;
  final result = Rxn<PositionCalcResult>();

  @override
  void onInit() {
    super.onInit();
    symbolController.addListener(() {
      currentSymbol.value = symbolController.text.trim().toUpperCase();
    });

    final args = Get.arguments;
    if (args is Map) {
      if (args['symbol'] != null && args['symbol'].toString().isNotEmpty) {
        symbolController.text = args['symbol'].toString();
        currentSymbol.value = args['symbol'].toString().toUpperCase();
      }
      if (args['maxCapital'] != null) {
        maxCapitalController.text = args['maxCapital'].toString();
      }
      if (args['entryPrice'] != null) {
        entryPriceController.text = args['entryPrice'].toString();
      }
      if (args['entryQuantity'] != null) {
        entryQuantityController.text = args['entryQuantity'].toString();
      }
      calculate();
    } else {
      _loadSavedParams();
    }
  }

  Future<void> _loadSavedParams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSymbol = prefs.getString(_keySymbol);
      final savedMaxCapital = prefs.getString(_keyMaxCapital);
      final savedEntryPrice = prefs.getString(_keyEntryPrice);
      final savedEntryQty = prefs.getString(_keyEntryQuantity);

      if (savedSymbol != null && savedSymbol.isNotEmpty) {
        symbolController.text = savedSymbol;
        currentSymbol.value = savedSymbol.toUpperCase();
      }
      if (savedMaxCapital != null && savedMaxCapital.isNotEmpty) {
        maxCapitalController.text = savedMaxCapital;
      }
      if (savedEntryPrice != null && savedEntryPrice.isNotEmpty) {
        entryPriceController.text = savedEntryPrice;
      }
      if (savedEntryQty != null && savedEntryQty.isNotEmpty) {
        entryQuantityController.text = savedEntryQty;
      }
    } catch (_) {}
    calculate();
  }

  Future<void> _saveParams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySymbol, symbolController.text.trim());
      await prefs.setString(_keyMaxCapital, maxCapitalController.text.trim());
      await prefs.setString(_keyEntryPrice, entryPriceController.text.trim());
      await prefs.setString(_keyEntryQuantity, entryQuantityController.text.trim());
    } catch (_) {}
  }

  void selectSymbol(String symbol) {
    symbolController.text = symbol;
    currentSymbol.value = symbol;
    calculate();
  }

  void resetFields() {
    symbolController.text = 'BTCUSDT';
    currentSymbol.value = 'BTCUSDT';
    maxCapitalController.text = '400000000';
    entryPriceController.text = '60000';
    entryQuantityController.text = '0.005';
    calculate();
  }

  double? get parsedEntryPrice => double.tryParse(entryPriceController.text.trim());

  double? get takeProfitChangePercent {
    final entry = parsedEntryPrice;
    final res = result.value;
    if (entry == null || entry <= 0 || res == null || res.takePrice <= 0) return null;
    return ((res.takePrice - entry) / entry) * 100;
  }

  double? get stopLossChangePercent {
    final entry = parsedEntryPrice;
    final res = result.value;
    if (entry == null || entry <= 0 || res == null || res.stopPrice <= 0) return null;
    return ((res.stopPrice - entry) / entry) * 100;
  }

  double? get riskRewardRatio {
    final entry = parsedEntryPrice;
    final res = result.value;
    if (entry == null || entry <= 0 || res == null) return null;
    final reward = (res.takePrice - entry).abs();
    final risk = (entry - res.stopPrice).abs();
    if (risk <= 0) return null;
    return reward / risk;
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
      if (Get.context != null) Get.snackbar('输入错误', '请输入交易对名称 (Symbol)');
      return;
    }

    final maxCapital = double.tryParse(maxCapitalController.text.trim());
    if (maxCapital == null || maxCapital <= 0) {
      if (Get.context != null) Get.snackbar('输入错误', '请输入有效的 Max Capital');
      return;
    }

    final entryPrice = double.tryParse(entryPriceController.text.trim());
    if (entryPrice == null || entryPrice <= 0) {
      if (Get.context != null) Get.snackbar('输入错误', '请输入有效的 Entry Price');
      return;
    }

    final entryQuantity = double.tryParse(entryQuantityController.text.trim());
    if (entryQuantity == null || entryQuantity <= 0) {
      if (Get.context != null) Get.snackbar('输入错误', '请输入有效的 Entry Quantity');
      return;
    }

    _saveParams();

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
      if (Get.context != null) Get.snackbar('计算失败', e.toString());
      result.value = null;
    } finally {
      isLoading(false);
    }
  }
}

