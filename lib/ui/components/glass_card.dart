import 'package:flutter/material.dart';
import 'tables/tradingview_table_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius = 14.0,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? TvTableTheme.tvBorderColor;
    final effectiveColor = color ?? TvTableTheme.tvCardBg;
    final effectiveGradient = gradient ?? TvTableTheme.tvCardGradient;

    Widget body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color != null ? effectiveColor : null,
        gradient: color == null ? effectiveGradient : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: 1.0,
        ),
        boxShadow: boxShadow ??
            const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );

    if (margin != EdgeInsets.zero) {
      body = Padding(padding: margin, child: body);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: TvTableTheme.tvBlue.withValues(alpha: 0.15),
          highlightColor: TvTableTheme.tvBlue.withValues(alpha: 0.08),
          child: body,
        ),
      );
    }

    return body;
  }
}
