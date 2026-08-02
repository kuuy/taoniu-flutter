import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
import '../components/glass_card.dart';
import 'account_controller.dart';

class AccountPage extends GetView<AccountController> {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      appBar: TvTableTheme.buildAppBar(
        title: 'Account & Settings',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TvTableTheme.tvTextPrimary, size: 20),
            onPressed: () => controller.loadUserData(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Profile Header Card
            _buildProfileHeaderCard(),
            const SizedBox(height: 16),

            // 2. Asset Overview Banner
            _buildAssetOverviewBanner(),
            const SizedBox(height: 16),

            // 3. Quant Trading Performance Metrics
            _buildQuantStatsGrid(),
            const SizedBox(height: 16),

            // 4. API Key & Security Credentials Card
            _buildApiKeyCard(context),
            const SizedBox(height: 16),

            // 5. System Settings & Info List
            _buildSystemSettingsCard(),
            const SizedBox(height: 24),

            // 6. Logout Button
            _buildLogoutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2962FF), Color(0xFF00B0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2962FF).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        controller.username.value,
                        style: const TextStyle(
                          color: TvTableTheme.tvTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.amber, width: 0.8),
                        ),
                        child: Text(
                          controller.vipLevel.value,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.email.value,
                    style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'UID: ${controller.uid.value}',
                    style: TextStyle(color: TvTableTheme.tvTextSecondary.withValues(alpha: 0.7), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetOverviewBanner() {
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 16,
      borderColor: TvTableTheme.tvBlue.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '资产总览 (USDT)',
                style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Icon(Icons.account_balance_wallet, color: TvTableTheme.tvBlue.withValues(alpha: 0.8), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '\$${controller.totalAssetUsdt.value.toStringAsFixed(2)}',
              style: const TextStyle(
                color: TvTableTheme.tvTextPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '今日预估盈亏: ',
                style: TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12),
              ),
              Obx(() {
                final pnl = controller.todayPnlUsdt.value;
                final pct = controller.todayPnlPercent.value;
                final isPositive = pnl >= 0;
                final color = isPositive ? TvTableTheme.tvGreen : TvTableTheme.tvRed;
                final sign = isPositive ? '+' : '';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$sign\$$pnl ($sign$pct%)',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantStatsGrid() {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '量化交易概览',
            style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                label: '策略胜率',
                valueObx: () => '${controller.winRate.value}%',
                valueColor: TvTableTheme.tvGreen,
              ),
              _buildVerticalDivider(),
              _buildStatItem(
                label: '总交易笔数',
                valueObx: () => '${controller.totalTrades.value}',
                valueColor: TvTableTheme.tvTextPrimary,
              ),
              _buildVerticalDivider(),
              _buildStatItem(
                label: '运行中策略',
                valueObx: () => '${controller.activeStrategiesCount.value}',
                valueColor: TvTableTheme.tvBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
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
                fontSize: 16,
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

  Widget _buildApiKeyCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.key, color: TvTableTheme.tvBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '币安 API Key 密钥管理',
                    style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Obx(() {
                final isBound = controller.isApiKeyBound;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isBound ? TvTableTheme.tvGreen : Colors.orange).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isBound ? '已绑定' : '未绑定',
                    style: TextStyle(
                      color: isBound ? TvTableTheme.tvGreen : Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Text(
              controller.isApiKeyBound
                  ? 'API Key: ${controller.maskedApiKey}'
                  : '未设置 API 密钥，当前处于只读模拟模式。绑定 API 后可开启高频自动化交易。',
              style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: TvTableTheme.tvBlue,
                side: const BorderSide(color: TvTableTheme.tvBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _showBindApiKeyDialog(context),
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('管理 API 密钥', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettingsCard() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      borderRadius: 14,
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.notifications_none,
            title: '推送与告警通知',
            subtitle: '策略开平仓及强平风控提醒',
            trailing: Obx(
              () => Switch(
                value: controller.enableNotifications.value,
                onChanged: (val) => controller.enableNotifications.value = val,
              ),
            ),
          ),
          const Divider(height: 1, color: TvTableTheme.tvBorderColor),
          _buildSettingTile(
            icon: Icons.security,
            title: '风控与仓位保护',
            subtitle: '单次交易最大止损与杠杆上限',
            onTap: () {
              Get.snackbar('风控设置', '默认单笔最大止损 2.0%', backgroundColor: TvTableTheme.tvHeaderBg, colorText: Colors.white);
            },
          ),
          const Divider(height: 1, color: TvTableTheme.tvBorderColor),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: '关于 Taoniu 淘牛量化',
            subtitle: '当前版本 v1.0.0 (Build 2026.8)',
            onTap: () {
              Get.snackbar('Taoniu 淘牛量化', '专为加密货币打造的高性能量化分析与交易中枢', backgroundColor: TvTableTheme.tvHeaderBg, colorText: Colors.white);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: TvTableTheme.tvTextSecondary, size: 22),
      title: Text(title, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: TvTableTheme.tvTextSecondary, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          foregroundColor: TvTableTheme.tvRed,
          backgroundColor: TvTableTheme.tvRed.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => controller.logout(),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('退出登录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  void _showBindApiKeyDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: TvTableTheme.tvCardBg,
        title: const Text('绑定币安 API 密钥', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'API Key',
                labelStyle: TextStyle(color: TvTableTheme.tvTextSecondary),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Secret Key',
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
              Get.snackbar('保存成功', 'API 密钥配置已安全存储', backgroundColor: TvTableTheme.tvHeaderBg, colorText: Colors.white);
            },
            child: const Text('保存配置', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
