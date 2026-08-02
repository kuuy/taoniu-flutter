import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
import '../components/glass_card.dart';
import 'plans_controller.dart';

class PlansPage extends GetView<PlansController> {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(
        title: 'Trading Plans',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: TvTableTheme.tvBlue, size: 22),
            onPressed: () => _showCreatePlanDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Summary Header Card
            _buildSummaryBanner(),
            const SizedBox(height: 16),

            // 2. Status Filter Tabs
            _buildFilterTabs(),
            const SizedBox(height: 16),

            // 3. Plans List
            Obx(() {
              final list = controller.filteredPlans;
              if (list.isEmpty) {
                return GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: const Center(
                    child: Text('暂无相关交易计划', style: TextStyle(color: TvTableTheme.tvTextSecondary)),
                  ),
                );
              }

              return Column(
                children: list.map((plan) => _buildPlanCard(context, plan)).toList(),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TvTableTheme.tvBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => _showCreatePlanDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('新建计划', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryBanner() {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '量化执行计划概览',
                style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.next_plan_rounded, color: TvTableTheme.tvBlue, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryStatItem(
                label: '平均目标收益率',
                valueObx: () => '+${controller.totalTargetProfit.value}%',
                valueColor: TvTableTheme.tvGreen,
              ),
              _buildVerticalDivider(),
              _buildSummaryStatItem(
                label: '运行中计划',
                valueObx: () => '${controller.activePlansCount.value}',
                valueColor: TvTableTheme.tvBlue,
              ),
              _buildVerticalDivider(),
              _buildSummaryStatItem(
                label: '已完成计划',
                valueObx: () => '${controller.completedPlansCount.value}',
                valueColor: TvTableTheme.tvTextPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatItem({
    required String label,
    required String Function() valueObx,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Obx(
            () => Text(
              valueObx(),
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 28,
      width: 1,
      color: TvTableTheme.tvBorderColor,
    );
  }

  Widget _buildFilterTabs() {
    return Obx(
      () => Row(
        children: controller.filters.map((f) {
          final isSelected = controller.selectedFilter.value == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                f,
                style: TextStyle(
                  color: isSelected ? Colors.white : TvTableTheme.tvTextSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: TvTableTheme.tvBlue,
              backgroundColor: TvTableTheme.tvHeaderBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? TvTableTheme.tvBlue : TvTableTheme.tvBorderColor),
              ),
              onSelected: (selected) {
                if (selected) controller.selectedFilter.value = f;
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, QuantPlan plan) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    plan.symbol,
                    style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: TvTableTheme.tvBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      plan.strategyType,
                      style: const TextStyle(color: TvTableTheme.tvBlue, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Obx(() {
                final isActive = plan.status.value == 'Active';
                final isCompleted = plan.status.value == 'Completed';
                final statusColor = isActive
                    ? TvTableTheme.tvGreen
                    : (isCompleted ? TvTableTheme.tvBlue : Colors.orange);

                return InkWell(
                  onTap: () => controller.togglePlanStatus(plan),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.play_arrow : Icons.pause,
                          color: statusColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan.status.value,
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Plan Parameters Grid
          Row(
            children: [
              _buildPlanDetailColumn('目标触发价', '\$${plan.targetPrice.toStringAsFixed(2)}'),
              _buildPlanDetailColumn('预期收益率', '+${plan.expectedProfitPercent}%', color: TvTableTheme.tvGreen),
              _buildPlanDetailColumn('止损价格', '\$${plan.stopLossPrice.toStringAsFixed(2)}', color: TvTableTheme.tvRed),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('策略进度', style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11)),
                  Text(
                    '${(plan.progressPercent * 100).toInt()}%',
                    style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Obx(
                () => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: plan.progressPercent,
                    backgroundColor: TvTableTheme.tvCanvasBg,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      plan.status.value == 'Active' ? TvTableTheme.tvBlue : TvTableTheme.tvTextSecondary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailColumn(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color ?? TvTableTheme.tvTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: TvTableTheme.tvCardBg,
        title: const Text('新建量化交易计划', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '交易标的 (如 BTCUSDT)',
                labelStyle: TextStyle(color: TvTableTheme.tvTextSecondary),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '目标买入价格 (\$)',
                labelStyle: TextStyle(color: TvTableTheme.tvTextSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消', style: TextStyle(color: TvTableTheme.tvTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TvTableTheme.tvBlue),
            onPressed: () {
              Get.back();
              Get.snackbar('创建成功', '新计划已存入策略引擎', backgroundColor: TvTableTheme.tvHeaderBg, colorText: Colors.white);
            },
            child: const Text('确认提交', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
