import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuantPlan {
  final String id;
  final String symbol;
  final String strategyType; // Grid, Scalping, DCA
  final double targetPrice;
  final double stopLossPrice;
  final double currentPrice;
  final double expectedProfitPercent;
  final double progressPercent;
  RxString status; // Active, Paused, Completed

  QuantPlan({
    required this.id,
    required this.symbol,
    required this.strategyType,
    required this.targetPrice,
    required this.stopLossPrice,
    required this.currentPrice,
    required this.expectedProfitPercent,
    required this.progressPercent,
    String status = 'Active',
  }) : status = status.obs;
}

class PlansController extends GetxController {
  final selectedFilter = 'All'.obs;
  final filters = ['All', 'Active', 'Paused', 'Completed'];

  final totalTargetProfit = 12.8.obs;
  final activePlansCount = 4.obs;
  final completedPlansCount = 18.obs;

  final plans = <QuantPlan>[
    QuantPlan(
      id: 'PLN-8091',
      symbol: 'BTCUSDT',
      strategyType: 'Spot Scalping',
      targetPrice: 66500.00,
      stopLossPrice: 62000.00,
      currentPrice: 64250.80,
      expectedProfitPercent: 15.5,
      progressPercent: 0.65,
      status: 'Active',
    ),
    QuantPlan(
      id: 'PLN-8092',
      symbol: 'ETHUSDT',
      strategyType: 'Grid Trading',
      targetPrice: 3800.00,
      stopLossPrice: 3200.00,
      currentPrice: 3480.25,
      expectedProfitPercent: 12.0,
      progressPercent: 0.80,
      status: 'Active',
    ),
    QuantPlan(
      id: 'PLN-8093',
      symbol: 'SOLUSDT',
      strategyType: 'DCA Accumulation',
      targetPrice: 160.00,
      stopLossPrice: 130.00,
      currentPrice: 145.30,
      expectedProfitPercent: 22.4,
      progressPercent: 0.45,
      status: 'Active',
    ),
    QuantPlan(
      id: 'PLN-8094',
      symbol: 'BNBUSDT',
      strategyType: 'Spot Scalping',
      targetPrice: 610.00,
      stopLossPrice: 560.00,
      currentPrice: 585.60,
      expectedProfitPercent: 8.5,
      progressPercent: 0.30,
      status: 'Paused',
    ),
  ].obs;

  List<QuantPlan> get filteredPlans {
    final f = selectedFilter.value;
    if (f == 'All') return plans;
    return plans.where((p) => p.status.value == f).toList();
  }

  void togglePlanStatus(QuantPlan plan) {
    if (plan.status.value == 'Active') {
      plan.status.value = 'Paused';
    } else if (plan.status.value == 'Paused') {
      plan.status.value = 'Active';
    }
  }

  void createNewPlan(String symbol, String strategyType, double targetPrice, double stopLoss) {
    final newId = 'PLN-${8095 + plans.length}';
    plans.insert(
      0,
      QuantPlan(
        id: newId,
        symbol: symbol.toUpperCase(),
        strategyType: strategyType,
        targetPrice: targetPrice,
        stopLossPrice: stopLoss,
        currentPrice: targetPrice * 0.95,
        expectedProfitPercent: 10.0,
        progressPercent: 0.10,
        status: 'Active',
      ),
    );
    Get.back();
    Get.snackbar(
      '新建计划',
      '交易计划 $newId 已创建并启动',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E222D),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: Color(0xFF089981)),
    );
  }
}
