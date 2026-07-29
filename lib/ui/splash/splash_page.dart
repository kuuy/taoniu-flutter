import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../components/tables/tradingview_table_theme.dart';
import 'splash_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.06).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure SplashController is registered/found
    Get.find<SplashController>();

    // Dark Mode Palette for Terminal Splash
    const bgColor1 = Color(0xFF0B0E14);
    const bgColor2 = TvTableTheme.tvCanvasBg;
    const bgColor3 = Color(0xFF181C27);

    const secondaryTextColor = TvTableTheme.tvTextSecondary;
    const accentColor = TvTableTheme.tvBlue;
    const cyanAccent = Color(0xFF00E5FF);
    final glowColor = accentColor.withValues(alpha: 0.3);
    final badgeBg = const Color(0xFF1E222D).withValues(alpha: 0.7);
    const badgeBorder = Color(0xFF2A2E39);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bgColor2,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgColor1, bgColor2, bgColor3],
            ),
          ),
          child: Stack(
            children: [
              // Ambient background glowing radial halo
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Center(
                    child: Transform.scale(
                      scale: _pulseAnimation.value * 1.3,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              glowColor,
                              glowColor.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Main content layout
              SafeArea(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),

                          // Animated Logo Icon Container
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accentColor.withValues(alpha: 0.25),
                                    cyanAccent.withValues(alpha: 0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.5),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.35),
                                    blurRadius: 28,
                                    spreadRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: cyanAccent.withValues(alpha: 0.2),
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.bolt_rounded,
                                size: 58,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Brand Title with ShaderMask Gradient
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFFFFF), Color(0xFF38BDF8), accentColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              'TAONIU',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: badgeBorder, width: 1.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.candlestick_chart_rounded,
                                  size: 14,
                                  color: accentColor,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'BINANCE SPOT QUANT TERMINAL',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryTextColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 54),

                          // Modern Progress Loader
                          const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                              strokeWidth: 2.5,
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            'INITIALIZING TERMINAL...',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: secondaryTextColor.withValues(alpha: 0.8),
                              letterSpacing: 1.5,
                            ),
                          ),

                          const Spacer(),

                          // Footer Version Watermark
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 13,
                                  color: secondaryTextColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'TAONIU QUANT ENGINE v1.0',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryTextColor.withValues(alpha: 0.6),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
