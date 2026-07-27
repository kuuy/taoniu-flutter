import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TvTableTheme.tvBorderColor),
      ),
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
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E222D), Color(0xFF181C27)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TvTableTheme.tvBorderColor),
      ),
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TvTableTheme.tvBorderColor),
      ),
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

  Widget _buildApiKeyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TvTableTheme.tvBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.key, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '币安 API Key 配置',
                    style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showApiKeyDialog(context),
                child: const Text('配置 / 编辑', style: TextStyle(color: TvTableTheme.tvBlue, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final isConfigured = controller.binanceApiKey.value.isNotEmpty;
            return Row(
              children: [
                Icon(
                  isConfigured ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: isConfigured ? TvTableTheme.tvGreen : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  controller.maskedApiKey,
                  style: TextStyle(
                    color: isConfigured ? TvTableTheme.tvTextPrimary : TvTableTheme.tvTextSecondary,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final apiKeyController = TextEditingController(text: controller.binanceApiKey.value);
    final secretKeyController = TextEditingController(text: controller.binanceSecretKey.value);

    Get.dialog(
      AlertDialog(
        backgroundColor: TvTableTheme.tvHeaderBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('配置币安 API Key', style: TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: apiKeyController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'API Key',
                  labelStyle: const TextStyle(color: TvTableTheme.tvTextSecondary),
                  filled: true,
                  fillColor: TvTableTheme.tvCanvasBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: secretKeyController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Secret Key',
                  labelStyle: const TextStyle(color: TvTableTheme.tvTextSecondary),
                  filled: true,
                  fillColor: TvTableTheme.tvCanvasBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消', style: TextStyle(color: TvTableTheme.tvTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TvTableTheme.tvBlue),
            onPressed: () => controller.saveApiKey(apiKeyController.text, secretKeyController.text),
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: TvTableTheme.tvHeaderBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TvTableTheme.tvBorderColor),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.wifi,
            title: '网络服务节点',
            subtitle: '币安 Spot Mainnet',
            trailingText: '正常',
            trailingColor: TvTableTheme.tvGreen,
          ),
          const Divider(height: 1, color: TvTableTheme.tvBorderColor),
          _buildSettingTile(
            icon: Icons.security,
            title: '通信加密算法',
            subtitle: 'JWE (RSA-OAEP + AES-GCM)',
            trailingText: '已启用',
            trailingColor: TvTableTheme.tvGreen,
          ),
          const Divider(height: 1, color: TvTableTheme.tvBorderColor),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: '应用版本',
            subtitle: 'Taoniu Quant v1.0.0',
            trailingText: '最新版',
            trailingColor: TvTableTheme.tvTextSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailingText,
    required Color trailingColor,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: TvTableTheme.tvCanvasBg,
        child: Icon(icon, color: TvTableTheme.tvTextSecondary, size: 18),
      ),
      title: Text(title, style: const TextStyle(color: TvTableTheme.tvTextPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: TvTableTheme.tvTextSecondary, fontSize: 11)),
      trailing: Text(trailingText, style: TextStyle(color: trailingColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: TvTableTheme.tvRed.withValues(alpha: 0.15),
          foregroundColor: TvTableTheme.tvRed,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: TvTableTheme.tvRed, width: 1.0),
          ),
        ),
        onPressed: () => controller.logout(),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text(
          '退出当前账号',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
