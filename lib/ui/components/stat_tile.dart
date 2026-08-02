import 'package:flutter/material.dart';
import 'tables/tradingview_table_theme.dart';
import 'glass_card.dart';

class StatTile extends StatelessWidget {
  final String title;
  final String value;
  final String? changeText;
  final bool? isPositive;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const StatTile({
    super.key,
    required this.title,
    required this.value,
    this.changeText,
    this.isPositive,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color trendColor = TvTableTheme.tvTextSecondary;
    IconData? trendIcon;

    if (isPositive != null) {
      trendColor = isPositive! ? TvTableTheme.tvGreen : TvTableTheme.tvRed;
      trendIcon = isPositive! ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: TvTableTheme.tvTextHeader,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: (iconColor ?? TvTableTheme.tvBlue).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: iconColor ?? TvTableTheme.tvBlue,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: TvTableTheme.tvTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          if (changeText != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (trendIcon != null)
                  Icon(
                    trendIcon,
                    size: 16,
                    color: trendColor,
                  ),
                Text(
                  changeText!,
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
