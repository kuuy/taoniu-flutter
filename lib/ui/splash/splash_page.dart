import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
import 'splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTableTheme.tvCanvasBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TvTableTheme.tvBlue.withValues(alpha: 0.15),
                border: Border.all(color: TvTableTheme.tvBlue.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: TvTableTheme.tvBlue.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt,
                size: 54,
                color: TvTableTheme.tvBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'TAONIU',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: TvTableTheme.tvTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Binance Spot Quant Trading Terminal',
              style: TextStyle(
                fontSize: 13,
                color: TvTableTheme.tvTextSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(TvTableTheme.tvBlue),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
