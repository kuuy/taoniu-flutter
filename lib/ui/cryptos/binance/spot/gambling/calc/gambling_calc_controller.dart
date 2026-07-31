import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taoniu/api/cryptos/binance/spot/gambling_api.dart';
import 'package:taoniu/models/binance/spot/gambling_calc.dart';

class GamblingCalcController extends GetxController {
  static const String _keySymbol = 'gambling_calc_symbol';
  static const String _keySide = 'gambling_calc_side';
  static const String _keyEntryPrice = 'gambling_calc_entry_price';
  static const String _keyEntryQuantity = 'gambling_calc_entry_quantity';

  final symbolController = TextEditingController(text: 'BTCUSDT');
  final entryPriceController = TextEditingController();
  final entryQuantityController = TextEditingController();

  final currentSymbol = 'BTCUSDT'.obs;
  final selectedSide = 1.obs; // 1: BUY / LONG, 2: SELL / SHORT
  final presetSymbols = const ['BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT', 'DOGEUSDT', 'XRPUSDT'];

  final isLoading = false.obs;
  final result = Rxn<GamblingCalcResult>();

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
      if (args['side'] != null) {
        final parsedSide = int.tryParse(args['side'].toString());
        if (parsedSide == 1 || parsedSide == 2) selectedSide.value = parsedSide!;
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
      final savedSide = prefs.getInt(_keySide);
      final savedEntryPrice = prefs.getString(_keyEntryPrice);
      final savedEntryQty = prefs.getString(_keyEntryQuantity);

      if (savedSymbol != null && savedSymbol.isNotEmpty) {
        symbolController.text = savedSymbol;
        currentSymbol.value = savedSymbol.toUpperCase();
      }
      if (savedSide != null && (savedSide == 1 || savedSide == 2)) {
        selectedSide.value = savedSide;
      }
      if (savedEntryPrice != null) {
        entryPriceController.text = savedEntryPrice;
      }
      if (savedEntryQty != null) {
        entryQuantityController.text = savedEntryQty;
      }
    } catch (_) {}
    calculate();
  }

  Future<void> _saveParams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySymbol, symbolController.text.trim());
      await prefs.setInt(_keySide, selectedSide.value);
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
    selectedSide.value = 1;
    entryPriceController.clear();
    entryQuantityController.clear();
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
      if (Get.context != null) Get.snackbar('输入错误', '请输入交易对名称 (Symbol)');
      return;
    }

    final entryPrice = double.tryParse(entryPriceController.text.trim());
    final entryQuantity = double.tryParse(entryQuantityController.text.trim());

    _saveParams();

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
      if (Get.context != null) Get.snackbar('计算失败', e.toString());
      result.value = null;
    } finally {
      isLoading(false);
    }
  }
}

