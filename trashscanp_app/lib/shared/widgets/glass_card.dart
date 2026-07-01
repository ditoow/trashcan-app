import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;
  final double borderRadius;
  final EdgeInsets padding;
  final bool hasPurpleTint;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.color = AppColors.glassBase,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16),
    this.hasPurpleTint = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: hasPurpleTint
                ? Color.alphaBlend(const Color(0x1A8538C7), color)
                : color,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.glassBorder, width: 0.5),
            gradient: hasPurpleTint
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x338538C7),
                      Color(0x0DFFFFFF),
                    ],
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
