import 'dart:ui';

import 'package:flutter/material.dart';

import 'tokens.dart';

/// 液态玻璃背后的背景：柔和三色渐变 + 两团大光斑
class UgkBackdrop extends StatelessWidget {
  const UgkBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark ? UgkColors.darkBackdrop : UgkColors.lightBackdrop;
    final glowA = dark ? UgkColors.darkGlowA : UgkColors.lightGlowA;
    final glowB = dark ? UgkColors.darkGlowB : UgkColors.lightGlowB;
    final alpha = dark ? 0.45 : 0.55;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: const Alignment(1.1, -0.55),
            child: _Glow(color: glowA.withValues(alpha: alpha), size: 360),
          ),
          Align(
            alignment: const Alignment(-1.1, 0.75),
            child: _Glow(color: glowB.withValues(alpha: alpha), size: 340),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
