import 'dart:ui';

import 'package:flutter/material.dart';

import 'tokens.dart';

/// 液态玻璃背后的彩色渐变背景
class UgkBackdrop extends StatelessWidget {
  const UgkBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark ? UgkColors.darkBackdrop : UgkColors.lightBackdrop;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          Align(
            alignment: Alignment(-1.3, -1.1),
            child: _BlurCircle(color: UgkColors.newBlue),
          ),
          Align(
            alignment: Alignment(1.4, 0.0),
            child: _BlurCircle(color: UgkColors.learnRed),
          ),
          Align(
            alignment: Alignment(-1.2, 1.3),
            child: _BlurCircle(color: UgkColors.reviewGreen),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
